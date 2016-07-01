class EtlWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  BASE_DIR = '/Users/agustinpagnoni/Documents/ITBA/2016-1/olap/tp/';
  ORDER_TYPES = [:sold, :debit, :credit, :credit_cuotas, :chargeback]

  def perform
    CSV.open(BASE_DIR + 'fact_table.csv', 'w', col_sep: '|') do |csv|
      # mail_to_shop_ids.each do |email, shop_ids|
      mail_to_shop_ids.each do |email, shop_ids|
        array_summary_values(shop_ids).each do |per_date_summ|
          csv << [digest(email), per_date_summ].flatten
        end
      end
    end
  end

  private

  def mail_to_shop_ids
    emails_path = BASE_DIR + 'emails.txt';
    emails = CSV.read(emails_path).flatten;
    ids = Client.where(email: emails).ids;
    email_to_shops = "SELECT c.email, cs.shop_id FROM clients c JOIN clients_shops cs ON cs.client_id = c.id WHERE c.id IN (?)";
    query = ActiveRecord::Base.send(:sanitize_sql_array, [email_to_shops, ids]);
    raw = ActiveRecord::Base.connection.execute(query);
    raw_array = raw.map(&:to_a) # [["email", "romard76@hotmail.com"], ["shop_id", "106"]]
    raw_array = raw_array.map {|r| [r[0][1], r[1][1]] }; # ["romard76@hotmail.com", "106"]
    mail_to_shop_ids_raw = raw_array.group_by {|r| r[0] };
    mail_to_shop_ids = mail_to_shop_ids_raw.map {|k,v| [k, v.map(&:second)] } # email -> id1,id2..
  end

  def array_summary_values(shop_ids)
    rows = []
    shop_ids.each do |shop_id|
      cl_ids = Clearing::Transaction.where.not(clearing_table_id: nil).where(shop_id: shop_id).pluck(:clearing_table_id)
      cuit = Clearing::Table.where(id: cl_ids).where.not(store_cuit: nil).pluck(:store_cuit).uniq[0]
      next if cuit.nil? # discard these, afterwards we can't link them to a paying shop
      cuit = cuit.gsub('-','').strip
      cuit = [160, 194].include?(cuit.getbyte(0)) ? cuit[1..-1] : cuit
      payed_debit = Clearing::Transaction.where.not(clearing_table_id: nil).where(shop_id: shop_id).where('amount_cents > 0').where(installments: '0').order(:pay_date).group(:pay_date).pluck(:pay_date, 'SUM(amount_cents)', 'COUNT(*)', 'cast(AVG(amount_cents) as int)');
      payed_credit = Clearing::Transaction.where.not(clearing_table_id: nil).where(shop_id: shop_id).where('amount_cents > 0').where(installments: '1').order(:pay_date).group(:pay_date).pluck(:pay_date, 'SUM(amount_cents)', 'COUNT(*)', 'cast(AVG(amount_cents) as int)');
      payed_credit_cuotas = Clearing::Transaction.where.not(clearing_table_id: nil).where(shop_id: shop_id).where('amount_cents > 0').where("installments <> '0' AND installments <> '1'").order(:pay_date).group(:pay_date).pluck(:pay_date, 'SUM(amount_cents)', 'COUNT(*)', 'cast(AVG(amount_cents) as int)');
      sold_per_day = Clearing::Transaction.anticipations.where(shop_id: shop_id).where('amount_cents > 0').order(:pay_date).group(:pay_date).pluck(:pay_date, 'SUM(amount_cents)', 'COUNT(*)', 'cast(AVG(amount_cents) as int)');
      chargeback_ids = Chargeback::Table.where(shop_id: shop_id).ids
      chargeback = Chargeback::Base.where(type: 'Chargeback::Chargeback', category: 'chargeback', chargeback_table_id: chargeback_ids).group(:presentation_date).pluck(:presentation_date, 'SUM(amount_cents)', 'COUNT(*)', 'cast(AVG(amount_cents) as int)')
      summary = {};
      sum2 = add_to_summary(payed_debit, summary, :debit);
      sum3 = add_to_summary(payed_credit, sum2, :credit);
      sum4 = add_to_summary(payed_credit_cuotas, sum3, :credit_cuotas);
      sum5 = add_to_summary(sold_per_day, sum4, :sold);
      sum6 = add_to_summary(chargeback, sum5, :chargeback);
      rows += rows_with_cuit(cuit, fill_with_zeroes(sum6))
    end
    rows
  end

  def add_to_summary(rows, sum, key)
    groupped = rows.group_by {|k| k[0]};
    groupped.each do |k,v|
      next if k.nil?
      k_clean = k.strftime("%Y-%m-%d")
      new_val = { key => v.map {|r| r[1..-1] }}
      if sum[k_clean].nil?
        sum[k_clean] = new_val
      else
        sum[k_clean] = sum[k_clean].merge(new_val)
      end
    end
    sum
  end

  # input: sum --> [date, {credit: [[..]], debit: [[..]], etc}]
  # output: [date, sold_sum, sold_count, sold_avg, debit_sum, debit_count, debit_avg, credit_sum, credit_count, credit_avg, cc_sum, cc_count, cc_avg, chargeback_sum, chargeback_count]
  def fill_with_zeroes(sum)
    filled = []
    sum.each do |arr|
      values_by_type = ORDER_TYPES.each.inject([]) do |_acum, type|
        to_add = arr[1][type].nil? ? [0,0,0] : arr[1][type].flatten
        _acum << to_add
      end
      zeroed = [arr[0]] + values_by_type
      filled << zeroed.flatten
    end
    filled
  end

  # output: [[date, sold_sum, sold_count, sold_avg, ..., cuit], [.., cuit]]
  def rows_with_cuit(cuit, arr)
    arr.map { |e| e << cuit }
  end

  def digest(string)
    Digest::SHA1.hexdigest(string)
  end
end
