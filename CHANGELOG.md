ToDo
- Autodetection in table data of: boolean and 'true' and 'false'. To render with red and green traffic-light image.
- Add tip to cell
- Add option :excel => false to column to remove from excel export
- Add option [:export][:type] => :xls, :xlsx, :pdf, :all, [:xls, :xlsx]
- Add option [:export][:table] => true to have a backup of the table
- Add :if => Proc.new to condition column presence

BugToFix
- link :name=> "pippo", body_type => icon, :url => "my_url" do not render default icons if not passed in yml
- Export: currency column must not be renderered as string

1.0.6 (October 11)
- Added Percentage support to :data_field

1.0.5
- If Currency column is nil, must output 0 currency formatted

1.0.2 (July 13, 2012)
- Update to Rails 3.0.14

1.0.1 (June 29, 2012)
- First working release

0.1.0 (June 18, 2012)
- first Release
