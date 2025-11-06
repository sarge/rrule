defmodule RRuleTest do
  use ExUnit.Case, async: true
  doctest RRule

  test "Uses UTC as local timezone" do
    {:ok, {occurrences, has_more}} =
      RRule.all_between(
        "DTSTART;VALUE=DATE:20201214\nRRULE:LOCAL-TZID=Pacific/Auckland;FREQ=DAILY;COUNT=2;",
        ~U[2020-12-13 00:00:00Z],
        ~U[2020-12-16 00:00:00Z]
      )

    assert occurrences == [
             ~U[2020-12-13 11:00:00Z],
             ~U[2020-12-14 11:00:00Z]
           ]

    refute has_more
  end

  test "Uses UTC as local timezone with the BYHOUR" do
    {:ok, {occurrences, has_more}} =
      RRule.all_between(
        "DTSTART;VALUE=DATE:20201214\nRRULE:LOCAL-TZID=UTC;FREQ=DAILY;BYHOUR=9,12,15;COUNT=2;",
        ~U[2020-12-13 00:00:00Z],
        ~U[2020-12-16 00:00:00Z]
      )

    assert occurrences == [
             ~U[2020-12-14 09:00:00Z],
             ~U[2020-12-14 12:00:00Z]
           ]

    refute has_more
  end

  test "Uses Pacific/Auckalnd as local timezone with the BYHOUR" do
    {:ok, {occurrences, has_more}} =
      RRule.all_between(
        "DTSTART;VALUE=DATE:20201214\nRRULE:LOCAL-TZID=Pacific/Auckland;FREQ=DAILY;BYHOUR=9,12,15;COUNT=2;",
        ~U[2020-12-13 00:00:00Z],
        ~U[2020-12-16 00:00:00Z]
      )

    assert occurrences == [
             ~U[2020-12-13 20:00:00Z],
             ~U[2020-12-13 23:00:00Z]
           ]

    refute has_more
  end

  test "Uses Include DTSTART" do
    {:ok, {occurrences, has_more}} =
      RRule.all_between(
        "DTSTART:20230101T100000Z\nRRULE:FREQ=DAILY;INTERVAL=2;COUNT=3;X-INCLUDE-DTSTART=TRUE",
        ~U[2023-01-01 00:00:00Z],
        ~U[2023-02-01 00:00:00Z]
      )

    assert occurrences == [
             ~U[2023-01-01 10:00:00Z],
             ~U[2023-01-03 10:00:00Z],
             ~U[2023-01-05 10:00:00Z],
             ~U[2023-01-07 10:00:00Z]
           ]

    refute has_more
  end

  test "Lists occurrences between for RRULE" do
    {:ok, {occurrences, has_more}} =
      RRule.all_between(
        "DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5",
        ~U[2012-01-01 09:00:00Z],
        ~U[2012-02-01 09:00:00Z]
      )

    assert occurrences == [
             ~U[2012-01-01 09:30:00Z],
             ~U[2012-01-02 09:30:00Z],
             ~U[2012-01-03 09:30:00Z],
             ~U[2012-01-04 09:30:00Z],
             ~U[2012-01-05 09:30:00Z]
           ]

    refute has_more
  end

  test "Lists occurrences between for RRULESET" do
    {:ok, {occurrences, has_more}} =
      RRule.all_between(
        ~s(DTSTART:20120101T093000Z\nRRULE:FREQ=MONTHLY;COUNT=100\nRDATE:20120201T023000Z,20120702T023000Z\nEXRULE:FREQ=MONTHLY;COUNT=2\nEXDATE:20120601T023000Z),
        ~U[2012-01-01 09:00:00Z],
        ~U[2012-12-01 09:00:00Z],
        2
      )

    assert occurrences == [
             ~U[2012-01-01 09:30:00Z],
             ~U[2012-02-01 02:30:00Z]
           ]

    assert has_more
  end

  test "Reports error for all_between when rule can't be parsed" do
    {:error, msg} =
      RRule.all_between(
        "DTSTART:2012010=DAILY;COUNT=5",
        ~U[2012-01-01 09:00:00Z],
        ~U[2012-02-01 09:00:00Z]
      )

    assert msg ==
             "RRule parsing error: `2012010=DAILY;COUNT=5` is not a valid datetime format for `DTSTART`."
  end

  test "Validates RRULE" do
    assert :ok ==
             RRule.validate("DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5")
  end

  test "Error for invalid RRULE" do
    assert {:error,
            "RRule parsing error: `DTSTA` is not a valid property name, expected one of: `RRULE,EXRULE,DTSTART,RDATE,EXDATE`"} ==
             RRule.validate("DTSTA:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5")
  end

  test "Retrieve DTSTART for RRULE" do
    {:ok, start_date} = RRule.get_start_date("DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5")

    assert start_date == ~U[2012-01-01 09:30:00Z]
  end

  test "Lists all occurrences for RRULE up to limit" do
    {:ok, occurrences} =
      RRule.all(
        "DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=100",
        10
      )

    assert occurrences == [
             ~U[2012-01-01 09:30:00Z],
             ~U[2012-01-02 09:30:00Z],
             ~U[2012-01-03 09:30:00Z],
             ~U[2012-01-04 09:30:00Z],
             ~U[2012-01-05 09:30:00Z],
             ~U[2012-01-06 09:30:00Z],
             ~U[2012-01-07 09:30:00Z],
             ~U[2012-01-08 09:30:00Z],
             ~U[2012-01-09 09:30:00Z],
             ~U[2012-01-10 09:30:00Z]
           ]
  end

  test "Returns error tuple when limit is exceeded" do
    {:error, msg} =
      RRule.all(
        "DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=100",
        65_536
      )

    assert msg == "Limit must be below 65,535"
  end
end
