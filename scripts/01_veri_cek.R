# EVDS'den serileri çekip data/raw/ altına CSV olarak yazar.
# Çalıştırma (proje kökünden):  Rscript scripts/01_veri_cek.R

source("R/evds.R")
readRenviron(".Renviron")

BASLANGIC <- as.Date("2005-01-01")   # TODO: başlangıç tarihini gerekçesiyle seç

seriler <- list(
  tufe = list(kod = "TP.FG.J0", aciklama = "TÜFE genel endeksi (2003=100), aylık")
  # TODO: kur serisini ekle. Karar vermen gerekenler:
  #   - hangi seri (alış / satış, döviz / efektif)?
  #   - günlük veriyi aylığa nasıl çevireceksin (ay ortalaması mı, ay sonu mu)?
  #     EVDS'de `frequency` ve `aggregationTypes` parametrelerine bak.
)

dir.create("data/raw", showWarnings = FALSE, recursive = TRUE)
for (ad in names(seriler)) {
  s <- seriler[[ad]]
  df <- evds_get(s$kod, start = BASLANGIC)
  yol <- file.path("data/raw", paste0(ad, ".csv"))
  write.csv(df, yol, row.names = FALSE)
  message(sprintf("%s: %d gözlem (%s – %s) → %s", s$aciklama, nrow(df),
                  min(df$tarih), max(df$tarih), yol))
}
