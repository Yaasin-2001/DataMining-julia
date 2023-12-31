using CSV
using HTTP
using Gumbo
using Cascadia
using TypedTables
using DataFrames

linkler = String[]

function scrape_turk_diziler_info(url)
    urlDonusu = HTTP.get(url)
    ayristirilmisSayfa = parsehtml(String(urlDonusu.body))

    tablolar = eachmatch(Selector("table.wikitable"), ayristirilmisSayfa.root)
    seri_bilgisi = Table(baslik = String[], bolum_sayisi = String[], sezon_sayisi = String[], durum = String[], kanal = String[])

    for tablo in tablolar[1:1]
        for satir in eachmatch(Selector("tr"), tablo)
            hucreler = eachmatch(Selector("td"), satir)
            if hucreler !== nothing && length(hucreler) >= 5
                baslik_hucresi = hucreler[1]
                baslik = strip(text(baslik_hucresi))
                link = ""
                link_elemanlari = eachmatch(Selector("a"), baslik_hucresi)
                if link_elemanlari !== nothing
                    for link_elemani in link_elemanlari
                        link = get(link_elemani.attributes, "href", "")
                        if startswith(link, "/wiki/")
                            link = "https://tr.wikipedia.org" * link
                            break
                        end
                    end
                end

                bolum_sayisi = strip(text(hucreler[2]))
                sezon_sayisi = strip(text(hucreler[3]))
                durum = strip(text(hucreler[4]))
                kanal = strip(text(hucreler[5]))

                push!(seri_bilgisi.baslik, baslik)
                push!(seri_bilgisi.bolum_sayisi, bolum_sayisi)
                push!(seri_bilgisi.sezon_sayisi, sezon_sayisi)
                push!(seri_bilgisi.durum, durum)
                push!(seri_bilgisi.kanal, kanal)
                push!(linkler, link)
            end
        end
    end
    return seri_bilgisi
end

function scrape_individual_page(link)
    urlDonusu = HTTP.get(link)
    ayristirilmisSayfa = parsehtml(String(urlDonusu.body))

    yönetmen = ""
    başrol = ""
    tür = ""
    gösterim_süresi = ""
    yayın_tarihi = ""
    yapım_şirketi = ""
    senarist = ""
    yapımcı = ""
    format = ""
    bölüm_sayısı = ""

    for bilgikutusu in eachmatch(Selector(".infobox"), ayristirilmisSayfa.root)
        for satir in eachmatch(Selector("tr"), bilgikutusu)
            hucreler = eachmatch(Selector("th, td"), satir)
            if length(hucreler) >= 2
                anaBaslik = strip(lowercase(text(hucreler[1])))
                detay = strip(text(hucreler[2]))
                if occursin("yönetmen", anaBaslik)
                    yönetmen = detay
                elseif occursin("başrol", anaBaslik)
                    başrol = detay
                elseif occursin("tür", anaBaslik)
                    tür = detay
                elseif occursin("gösterim süresi", anaBaslik)
                    gösterim_süresi = detay
                elseif occursin("yayın tarihi", anaBaslik)
                    yayın_tarihi = detay
                elseif occursin("şirketi", anaBaslik)
                    yapım_şirketi = detay
                elseif occursin("senarist", anaBaslik)
                    senarist = detay
                elseif occursin("yapımcı", anaBaslik)
                    yapımcı = detay
                elseif occursin("format", anaBaslik)
                    if occursin("dizisi", detay)
                        format = detay
                    end 
                elseif occursin("bölüm sayısı", anaBaslik)
                    bölüm_sayısı = detay
                end
            end
        end
    end

    return yönetmen, başrol, tür, gösterim_süresi, yayın_tarihi, yapım_şirketi, senarist, yapımcı, format, bölüm_sayısı
end



url = "https://tr.wikipedia.org/wiki/Türk_dizileri_listesi"
turk_diziler = scrape_turk_diziler_info(url)

Yonetmen = String[]
Basrol = String[]
Tur = String[]
Gosterim_suresi = String[]
Yayin_tarihi = String[]
Yapim_sirketi = String[]
Senarist = String[]
Yapimci = String[]
Format = String[]
Bolum_Sayisi = String[]

for link in linkler
    if startswith(link, "https")
        yönetmen, başrol, tür, gösterim_süresi, yayın_tarihi, yapım_şirketi, senarist, yapımcı, format, bölüm_sayısı = scrape_individual_page(link)
        push!(Yonetmen, yönetmen)
        push!(Basrol, başrol)
        push!(Tur, tür)
        push!(Gosterim_suresi, gösterim_süresi)
        push!(Yayin_tarihi, yayın_tarihi)
        push!(Yapim_sirketi, yapım_şirketi)
        push!(Senarist, senarist)
        push!(Yapimci, yapımcı)
        push!(Format, format)
        push!(Bolum_Sayisi, bölüm_sayısı)
    else
        push!(Yonetmen, "")
        push!(Basrol, "")
        push!(Tur, "")
        push!(Gosterim_suresi, "")
        push!(Yayin_tarihi, "")
        push!(Yapim_sirketi, "")
        push!(Senarist, "")
        push!(Yapimci, "")
        push!(Format, "")
        push!(Bolum_Sayisi, "")
    end
end


turk_diziler_df = DataFrame(
    Baslik = turk_diziler.baslik,
    BolumSayisi = turk_diziler.bolum_sayisi,
    SezonSayisi = turk_diziler.sezon_sayisi,
    Durum = turk_diziler.durum,
    Kanal = turk_diziler.kanal,
    Yonetmen = Yonetmen,
    Basrol = Basrol,
    Tur = Tur,
    Gosterim_suresi = Gosterim_suresi,
    Yayin_tarihi = Yayin_tarihi,
    Yapim_sirketi = Yapim_sirketi,
    Senarist = Senarist,
    Yapimci = Yapimci,
    Format = Format,
    Bolum_Sayisi = Bolum_Sayisi
)
    
    Dizinin_isminin_uzunluğu =  Int64[]
    Dizinin_Başlangıç_Yılı = String[]
    Sezon_Sayısı = Int64[]
    Romantik =  Int64[]
    Dram =  Int64[]
    Gençlik =  Int64[]
    Komedi =  Int64[]
    Macera =  Int64[]
    KanalD = Int64[]
    StarTV= Int64[]
    TRT1 = Int64[]
    ATV = Int64[]
    ShowTV = Int64[]
    Fox = Int64[]
    SamanyoluTV = Int64[]
    TV8 = Int64[]
    Televizyon_Dizisi =  Int64[]
    İnternet_Dizisi =  Int64[]
    Bölüm_Süresi =  Int64[]
    Toplam_Bölüm_Sayısı = Int64[]
    Sezon_Başına_Bölüm = Float64[]
    

    for i in turk_diziler.baslik
         push!(Dizinin_isminin_uzunluğu, length(i))
    end
    
    for i in Tur
        if occursin("Romantik", i)
            push!(Romantik, 1)
        else
            push!(Romantik, 0)
        end
   end
    for i in Tur
        if occursin("Dram", i)
            push!(Dram, 1)
        else
            push!(Dram, 0)
        end
   end
   for i in Tur
        if occursin("Gençlik", i)
            push!(Gençlik, 1)
        else
            push!(Gençlik, 0)
        end
    end
    for i in Tur
        if occursin("Komedi", i)
            push!(Komedi, 1)
        else
            push!(Komedi, 0)
        end
    end
    for i in Tur
        if occursin("Macera", i)
            push!(Macera, 1)
        else
            push!(Macera, 0)
        end
    end
    for i in turk_diziler.kanal
        if occursin("Kanal D", i)
            push!(KanalD, 1)
        else
            push!(KanalD, 0)
        end
    end
    for i in turk_diziler.kanal
        if occursin("Star TV", i)
            push!(StarTV, 1)
        else
            push!(StarTV, 0)
        end
    end
    for i in turk_diziler.kanal
        if occursin("TRT 1", i)
            push!(TRT1, 1)
        else
            push!(TRT1, 0)
        end
    end
    for i in turk_diziler.kanal
        if occursin("atv", i)
            push!(ATV, 1)
        else
            push!(ATV, 0)
        end
    end
    for i in turk_diziler.kanal
        if occursin("Show TV", i)
            push!(ShowTV, 1)
        else
            push!(ShowTV, 0)
        end
    end
    for i in turk_diziler.kanal
        if occursin("FOX", i)
            push!(Fox, 1)
        else
            push!(Fox, 0)
        end
    end
    for i in turk_diziler.kanal
        if occursin("Samanyolu TV", i)
            push!(SamanyoluTV, 1)
        else
            push!(SamanyoluTV, 0)
        end
    end
    for i in turk_diziler.kanal
        if occursin("TV8", i)
            push!(TV8, 1)
        else
            push!(TV8, 0)
        end
    end
    for i in Format
        if occursin("Televizyon dizisi", i)
            push!(Televizyon_Dizisi, 1)
        else
            push!(Televizyon_Dizisi, 0)
        end
    end
    for i in Format
        if occursin("İnternet dizisi", i)
            push!(İnternet_Dizisi, 1)
        else
            push!(İnternet_Dizisi, 0)
        end
    end
    function convert_to_int(str)
        # Sayısal değerleri bul
        num_str = match(r"\d+", str)
    
        # Eğer sayısal değer bulunursa, onu integer'a çevir
        if num_str !== nothing
            return parse(Int, num_str.match)
        else
            return 0
        end
    end
    for i in turk_diziler.sezon_sayisi
        push!(Sezon_Sayısı, convert_to_int(i))
    end
    
    for i in Gosterim_suresi
        push!(Bölüm_Süresi, convert_to_int(i))
    end
    for i in Bolum_Sayisi
        push!(Toplam_Bölüm_Sayısı, convert_to_int(i))
    end
    
    for i in 1:length(Bolum_Sayisi)
        k = round(Toplam_Bölüm_Sayısı[i] / Sezon_Sayısı[i])
        push!(Sezon_Başına_Bölüm, k)    
    end

    for i in Yayin_tarihi
        # Veriyi boşluğa göre ayır
        parçalar = split(i, " ")
        if startswith(i, "1.")
            if length(parçalar) >= 5
            push!(Dizinin_Başlangıç_Yılı, parçalar[5])
            else
            push!(Dizinin_Başlangıç_Yılı, "0")
            end
        else
            if length(parçalar) >= 3
            push!(Dizinin_Başlangıç_Yılı, parçalar[3])
            else
            push!(Dizinin_Başlangıç_Yılı, "0")
            end  
        end
    end




train_members_df = DataFrame(
    Dizinin_İsmi = turk_diziler.baslik,
    Dizinin_Başlangıç_Yılı = Dizinin_Başlangıç_Yılı,
    Dizinin_isminin_uzunluğu = Dizinin_isminin_uzunluğu,
    Romantik = Romantik,
    Dram = Dram,
    Gençlik = Gençlik,
    Komedi = Komedi,
    Macera = Macera,
    KanalD = KanalD,
    StarTV= StarTV,
    TRT1 = TRT1,
    ATV = ATV,
    ShowTV = ShowTV,
    Fox = Fox,
    SamanyoluTV = SamanyoluTV,
    TV8 = TV8,
    Televizyon_Dizisi = Televizyon_Dizisi,
    İnternet_Dizisi = İnternet_Dizisi,
    Bölüm_Süresi = Bölüm_Süresi,
    Toplam_Bölüm_Sayısı = Toplam_Bölüm_Sayısı,
    Sezon_Başına_Bölüm_Sayısı = Sezon_Başına_Bölüm,
    Sezon_Sayısı = Sezon_Sayısı
)

CSV.write("2024_yilin_diziler.csv", train_members_df)