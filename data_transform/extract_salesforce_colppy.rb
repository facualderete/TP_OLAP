# Salesforce Data
def merge_salesforce_colppy
  base_dir = '/Users/agustinpagnoni/Documents/ITBA/2016-1/olap/tp/'
  salesforce_path = base_dir + 'salesforce.csv'
  colppy_path = base_dir + 'colppy.csv'
  geography_path = base_dir + 'geography.txt'
  emails_path = base_dir + 'emails.txt'
  salesforce = CSV.read(salesforce_path, { headers: true, header_converters: :symbol, encoding: 'windows-1252:UTF-8' });
  [:razon_social, :direccion, :iva].each do |col_name|
    salesforce.delete(col_name)
  end
  # example
  # ["Empanadas Gourmet", "5/19/15", "CABA", "1406", "CABA", "Argentina", "marianoc2@empanadasgourmet.com.ar"]

  colppy = CSV.read(colppy_path, { col_sep: ';', headers: true, encoding: 'windows-1252:UTF-8' });
  ["Nombre de la oportunidad", "Etapa", "Nodo", "Descripcion"].each do |col_name|
    colppy.delete(col_name)
  end
  colppy_by_email = colppy.to_a.group_by {|row| row[4] };
  # example
  # ["229,90", "19/05/2015", "1", "Débito Automatico CBU", "Restaurant", "Web"]

  CSV.open(base_dir + 'shops_alone2.txt', 'w', col_sep: '|') do |csv|
    salesforce.each do |row|
      next if row[:email].blank? || colppy_by_email[row[:email]].blank?
      colppy_by_email[row[:email]].first.delete row[:email];
      colppy_data = colppy_by_email[row[:email]].first;
      colppy_data[1] = colppy_data[1].to_date.strftime("%Y-%m-%d");
      row[:email] = Digest::SHA1.hexdigest row[:email];
      row[:cuit] = row[:cuit].gsub('-','').strip
      row_filtered = [:nombre_fantasia, :email, :zipcode, :cuit].map { |c| row[c] };
      csv << [row_filtered + colppy_data].flatten.map {|data| data.try(:downcase)}
    end
  end

  shops_a = CSV.read(base_dir + 'shops_alone2.txt', col_sep: '|');
  shops_csv = CSV.open(base_dir + 'shops_alone2.csv', 'w') {|csv| csv + shops_a.to_a };

  CSV.open(base_dir + 'geography.txt', 'w', col_sep: '|') do |csv|
    salesforce.each do |row|
      row_filtered = [:zipcode, :ciudad, :provincia, :pais].map { |c| row[c] }
      csv << row_filtered.map {|data| data.try(:downcase)}
    end
  end


  geography = CSV.read(geography_path, { headers: true, col_sep: '|' , header_converters: :symbol })
  geo_by_zip = geography.to_a.group_by {|r| r[0]}
  geo_by_zip = geo_by_zip.map { |k,v| [k, v.first] }
  geo_by_zip = geo_by_zip.map {|k,v| v }
  CSV.open(base_dir + 'geography_uniq_by_zipcode.txt', 'w', col_sep: '|') do |csv|
    geo_by_zip.each do |row|
      csv << row
    end
  end

end


def extras
  base_dir = '/Users/agustinpagnoni/Documents/ITBA/2016-1/olap/tp/'
  CSV.open(base_dir + 'emails_existent.txt', 'w') do |csv|
      emails.each do |row|
        csv << [row]
      end
    end
end
