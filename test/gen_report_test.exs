defmodule GenReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @file_name "gen_report.csv"
  @report_files_list ["report1.csv", "report2.csv", "report3.csv"]

  describe "execute/1" do
    test "When passing a file name, returns a report" do
      response = GenReport.execute(@file_name)

      assert ReportFixture.build() == response
    end

    test "When no file name was given, returns an error" do
      response = GenReport.execute()

      assert response == {:error, :no_file_was_given}
    end
  end

  describe "execute_from_many" do
    test "When passing a list of files, returns a report" do
      response = GenReport.execute_from_many(@report_files_list)

      assert ReportFixture.build() == response
    end
  end
end
