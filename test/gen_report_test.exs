defmodule GenReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @file_name "gen_report.csv"

  describe "build/1" do
    test "When passing a file name, returns a report" do
      response = GenReport.execute(@file_name)

      assert ReportFixture.build() == response
    end

    test "When no file name was given, returns an error" do
      response = GenReport.execute()

      assert response == {:error, :no_file_was_given}
    end
  end
end
