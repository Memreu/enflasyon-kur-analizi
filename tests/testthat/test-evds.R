source(file.path("..", "..", "R", "evds.R"))

test_that("URL EVDS'nin beklediği biçimde kuruluyor", {
  u <- evds_url(c("TP.FG.J0", "TP.DK.USD.A.YTL"), as.Date("2020-01-01"), as.Date("2024-12-31"))
  expect_equal(
    u,
    "https://evds3.tcmb.gov.tr/igmevdsms-dis/series=TP.FG.J0-TP.DK.USD.A.YTL&startDate=01-01-2020&endDate=31-12-2024&type=json"
  )
  expect_match(evds_url("X", Sys.Date() - 1, Sys.Date(), frequency = 5), "&frequency=5$")
  expect_error(evds_url("X", as.Date("2024-01-01"), as.Date("2020-01-01")))
})

test_that("tarih biçimleri çözülüyor", {
  expect_equal(evds_parse_date(c("2020-1", "2020-12")), as.Date(c("2020-01-01", "2020-12-01")))
  expect_equal(evds_parse_date("15-01-2020"), as.Date("2020-01-15"))
  expect_equal(evds_parse_date("2021"), as.Date("2021-01-01"))
  expect_error(evds_parse_date("01/2020"))
})

test_that("JSON yanıtı veri çerçevesine dönüşüyor, boş değerler NA oluyor", {
  json <- jsonlite::fromJSON(test_path("fixtures", "evds_aylik.json"), simplifyVector = FALSE)
  df <- evds_parse(json, c("TP.FG.J0", "TP.DK.USD.A.YTL"))
  expect_named(df, c("tarih", "TP_FG_J0", "TP_DK_USD_A_YTL"))
  expect_equal(nrow(df), 3)
  expect_s3_class(df$tarih, "Date")
  expect_type(df$TP_FG_J0, "double")
  expect_true(is.na(df$TP_DK_USD_A_YTL[3]))
})

test_that("boş yanıt anlaşılır bir hata veriyor", {
  expect_error(evds_parse(list(items = list()), "X"), "boş yanıt")
})

test_that("API anahtarı yoksa istek gönderilmiyor", {
  expect_error(evds_get("TP.FG.J0", as.Date("2020-01-01"), api_key = ""), "EVDS_API_KEY")
})
