require 'test_helper'

class RecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @record = records(:one)
  end

  test "should get index" do
    get records_url
    assert_response :success
  end

  test "should get new" do
    get new_record_url
    assert_response :success
  end

  test "should create record" do
    assert_difference('Record.count') do
      post records_url, params: {record: {abstract: @record.abstract, accnum: @record.accnum, age: @record.age, author: @record.author, bpv: @record.bpv, cosmin_id: @record.cosmin_id, cu: @record.cu, disease: @record.disease, doi: @record.doi, fs: @record.fs, ghp: @record.ghp, instrument: @record.instrument, issn: @record.issn, issue: @record.issue, journal: @record.journal, oc: @record.oc, oql: @record.oql, pnp: @record.pnp, pubyear: @record.pubyear, ss: @record.ss, startpage: @record.startpage, title: @record.title, tmi: @record.tmi, url: @record.url, user_email: @record.user_email}}
    end

    assert_redirected_to record_url(Record.last)
  end

  test "should show record" do
    get record_url(@record)
    assert_response :success
  end

  test "should get edit" do
    get edit_record_url(@record)
    assert_response :success
  end

  test "should update record" do
    patch record_url(@record), params: {record: {abstract: @record.abstract, accnum: @record.accnum, age: @record.age, author: @record.author, bpv: @record.bpv, cosmin_id: @record.cosmin_id, cu: @record.cu, disease: @record.disease, doi: @record.doi, fs: @record.fs, ghp: @record.ghp, instrument: @record.instrument, issn: @record.issn, issue: @record.issue, journal: @record.journal, oc: @record.oc, oql: @record.oql, pnp: @record.pnp, pubyear: @record.pubyear, ss: @record.ss, startpage: @record.startpage, title: @record.title, tmi: @record.tmi, url: @record.url, user_email: @record.user_email}}
    assert_redirected_to record_url(@record)
  end

  test "should destroy record" do
    assert_difference('Record.count', -1) do
      delete record_url(@record)
    end

    assert_redirected_to records_url
  end
end
