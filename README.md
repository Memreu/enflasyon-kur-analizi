# Enflasyon ve kurun anatomisi

[![test](https://github.com/Memreu/enflasyon-kur-analizi/actions/workflows/test.yml/badge.svg)](https://github.com/Memreu/enflasyon-kur-analizi/actions/workflows/test.yml)

Türkiye'de TÜFE ve USD/TRY serilerinde **yapısal kırılmaları** bulmak ve tahmin modellerini **kayan pencereli (rolling-origin) değerlendirmeyle** karşılaştırmak için bir R çalışması. Veri kaynağı TCMB Elektronik Veri Dağıtım Sistemi (EVDS).

> 🚧 Çalışma devam ediyor. Bulgular ve yorumlar analiz ilerledikçe eklenecek.

## Araştırma soruları

1. TÜFE ve kur serileri durağan mı? Hangi dönüşümle durağanlaşıyor?
2. Serilerde yapısal kırılma var mı, varsa ne zaman?
3. Hangi tahmin modeli (naif, ETS, SARIMA) kayan pencereli testte daha iyi? Tahmin aralıkları gerçekten nominal kapsama oranını sağlıyor mu?

## Yol haritası

- [x] Repo iskeleti ve EVDS veri çekme fonksiyonu
- [ ] Veriyi çek ve sakla
- [ ] Keşifçi analiz
- [ ] Durağanlık testleri (ADF, KPSS)
- [ ] Yapısal kırılma testleri (Bai–Perron)
- [ ] Tahmin modelleri ve rolling-origin değerlendirme
- [ ] Bulgular ve sınırlılıklar

## Kurulum

```bash
git clone https://github.com/Memreu/enflasyon-kur-analizi.git
cd enflasyon-kur-analizi
```

1. EVDS'de hesap aç ve "Profilim" sayfasından API anahtarını kopyala.
2. `.Renviron.example` dosyasını `.Renviron` olarak kopyala ve anahtarını yaz. Bu dosya `.gitignore` içinde; repoya girmez.
3. R'da bağımlılıkları kur: `install.packages(c("httr2", "jsonlite", "testthat"))`

```bash
Rscript scripts/01_veri_cek.R          # → data/raw/
Rscript -e 'testthat::test_dir("tests/testthat")'
```

## Klasör yapısı

```
├── R/
│   └── evds.R              # EVDS web servisi istemcisi
├── scripts/
│   └── 01_veri_cek.R       # Veriyi çekip data/raw/ altına yazar
├── analysis/               # Quarto analiz belgeleri
├── data/raw/               # Ham veri (repoya girmez, betikle üretilir)
├── tests/testthat/         # Birim testleri
└── .github/workflows/      # CI
```

## Veri

[TCMB EVDS](https://evds3.tcmb.gov.tr/). EVDS kullanım şartlarına göre veriler kaynak gösterilerek kullanılabilir. Ham veri repoya eklenmez; herkes kendi API anahtarıyla betiği çalıştırarak aynı veriyi üretebilir.

---

Bu proje [MIT lisansı](LICENSE) ile paylaşılmaktadır.

**Mehmet Emre Ünlü** · [GitHub](https://github.com/Memreu) · [LinkedIn](https://www.linkedin.com/in/memreu) · [Kaggle](https://www.kaggle.com/memreu)
