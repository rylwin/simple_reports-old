# SimpleReports
require "open-uri" # for including static google map images in prawn
require 'action_view'
require 'active_record'
require 'geokit'

require 'simple_reports/report/base'
require 'simple_reports/report/table/row'
require 'simple_reports/report/table/map_row'
require 'simple_reports/report/table/cached_row'
require 'simple_reports/report/table/base'
require 'simple_reports/report/table/map'
require 'simple_reports/helpers/reports_text_helper'
require 'simple_reports/helpers/reports_excel_helper'
require 'simple_reports/helpers/reports_html_helper'
require 'simple_reports/helpers/reports_latex_helper'
require 'simple_reports/helpers/reports_prawn_helper'
require 'simple_reports/helpers/reports_chart_helper'
require 'simple_reports/helpers/simple_reports_helper'

ActionView::Base.send :include, SimpleReportsHelper

include ActionView::Helpers::NumberHelper

class SimpleReports
  MAP = {}
end