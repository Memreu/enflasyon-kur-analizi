# TCMB EVDS web servisi için küçük bir istemci.
#
# Servis, parametreleri sorgu dizesi olarak değil URL yolunun sonuna eklenmiş
# biçimde bekler ve API anahtarını "key" başlığında ister:
#   https://evds3.tcmb.gov.tr/igmevdsms-dis/series=TP.FG.J0&startDate=01-01-2020&endDate=01-12-2024&type=json

EVDS_BASE_URL <- "https://evds3.tcmb.gov.tr/igmevdsms-dis"

#' EVDS sorgu URL'si oluşturur
#'
#' @param series Seri kodları (karakter vektörü), ör. "TP.FG.J0".
#' @param start,end Date nesneleri.
#' @param frequency İsteğe bağlı frekans kodu (EVDS belgelerine bak).
#' @param base_url Servis adresi.
evds_url <- function(series, start, end, frequency = NULL, base_url = EVDS_BASE_URL) {
  stopifnot(is.character(series), length(series) >= 1,
            inherits(start, "Date"), inherits(end, "Date"), start <= end)
  params <- c(
    series = paste(series, collapse = "-"),
    startDate = format(start, "%d-%m-%Y"),
    endDate = format(end, "%d-%m-%Y"),
    type = "json",
    frequency = if (is.null(frequency)) NULL else as.character(frequency)
  )
  paste0(sub("/$", "", base_url), "/", paste(names(params), params, sep = "=", collapse = "&"))
}

# EVDS tarih metnini Date'e çevirir: "2020-1" (aylık), "2020" (yıllık), "15-01-2020" (günlük).
evds_parse_date <- function(x) {
  out <- rep(as.Date(NA), length(x))
  aylik <- grepl("^\\d{4}-\\d{1,2}$", x)
  yillik <- grepl("^\\d{4}$", x)
  gunluk <- grepl("^\\d{1,2}-\\d{1,2}-\\d{4}$", x)
  out[aylik] <- as.Date(paste0(x[aylik], "-01"), format = "%Y-%m-%d")
  out[yillik] <- as.Date(paste0(x[yillik], "-01-01"), format = "%Y-%m-%d")
  out[gunluk] <- as.Date(x[gunluk], format = "%d-%m-%Y")
  if (anyNA(out[!is.na(x)])) stop("Tanınmayan tarih biçimi: ", x[is.na(out) & !is.na(x)][1])
  out
}

#' EVDS JSON yanıtını veri çerçevesine çevirir
#'
#' Seri sütunlarının adında "." yerine "_" kullanılır (EVDS'nin yanıt biçimi).
#' @param json `jsonlite::fromJSON(..., simplifyVector = FALSE)` çıktısı.
#' @param series İstenen seri kodları.
evds_parse <- function(json, series) {
  items <- json$items
  if (length(items) == 0) stop("EVDS boş yanıt döndürdü; seri kodlarını ve tarih aralığını kontrol et.")
  cols <- gsub(".", "_", series, fixed = TRUE)
  out <- data.frame(tarih = evds_parse_date(vapply(items, function(i) i$Tarih, character(1))))
  for (k in seq_along(cols)) {
    out[[cols[k]]] <- vapply(items, function(i) {
      v <- i[[cols[k]]]
      if (is.null(v) || identical(v, "")) NA_real_ else as.numeric(v)
    }, numeric(1))
  }
  out
}

#' EVDS'den seri çeker
#'
#' @param api_key EVDS API anahtarı. Varsayılan olarak `EVDS_API_KEY` ortam değişkeni.
evds_get <- function(series, start, end = Sys.Date(), frequency = NULL,
                     api_key = Sys.getenv("EVDS_API_KEY")) {
  if (!nzchar(api_key)) stop("EVDS_API_KEY tanımlı değil. .Renviron.example dosyasına bak.")
  resp <- httr2::request(evds_url(series, start, end, frequency)) |>
    httr2::req_headers(key = api_key) |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform()
  evds_parse(httr2::resp_body_json(resp), series)
}
