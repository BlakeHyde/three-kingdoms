;;; chapter-1.scm — 三國演義 第一回
;;;
;;; A hand-written structural reading of chapter 1: what places it names, who appears,
;;; and what happens, in narrative order.
;;;
;;; This is notes, not build input. Nothing reads it. It exists to be argued with: the
;;; atlas in source/ is a thin projection of each chapter (a handful of pins and a
;;; control list), and this is the fuller thing that projection is drawn from, so the
;;; two can be compared by eye.
;;;
;;; Written against the three cached editions, not from memory:
;;;   wikisource_zh   Chinese, Mao Zonggang recension
;;;   gutenberg_zh    Chinese, Project Gutenberg #23950
;;;   brewitt_en      English, Brewitt-Taylor 1925, Project Gutenberg #77416
;;;
;;; Conventions:
;;;   (atlas-id x)     the corresponding id in source/, or #f if the atlas omits it
;;;   (on-map? #t/#f)  whether chapter 1 of the atlas currently shows it
;;;   (editions ...)   noted only where the editions disagree

(chapter 1

  (title
    (chinese "宴桃園豪傑三結義　斬黃巾英雄首立功")
    (brewitt "Feast in the Garden of Peaches: Brotherhood Sworn; Slaughter of Rebels: The Brothers Heroes")
    (atlas   "Three Heroes Swear Brotherhood in the Peach Garden; Heroes Win Their First Merit Against the Yellow Turbans"))

  (year 184)
  (reign-period "中平元年")

  ;; ------------------------------------------------------------------ places

  (places

    (place zhuo
      (hanzi "涿") (also "涿縣" "涿郡")
      (atlas-id zhuo) (on-map? #t)
      (role "Liu Bei's home county. The call for volunteers is posted here; the peach
             garden is behind Zhang Fei's farm nearby."))

    (place youzhou
      (hanzi "幽州")
      (atlas-id ji) (on-map? #t)
      (role "The province Zhang Jue invades. Liu Yan governs it and issues the call.")
      (note "The atlas point is the provincial seat. It carries the hanzi 幽州 rather
             than the city name 薊, because the novel never uses 薊."))

    (place julu
      (hanzi "鉅鹿")
      (atlas-id #f) (on-map? #f)
      (role "The Zhang brothers' home commandery. Named once, as their origin — no
             action happens here.")
      (note "The Brewitt-Taylor chapter title tradition puts the chapter's victory
             'at Julu'. The text does not: nothing is fought here."))

    (place daxing-shan
      (hanzi "大興山")
      (atlas-id daxingshan) (on-map? #t)
      (role "The brothers' first battle, against Cheng Yuanzhi and Deng Mao."))

    (place qingzhou
      (hanzi "青州")
      (atlas-id qingzhou) (on-map? #t)
      (role "Besieged by the rebels; relieved by Liu Bei and Zou Jing with an ambush."))

    (place guangzong
      (hanzi "廣宗")
      (atlas-id guangzong) (on-map? #t)
      (role "Zhang Jue's position, besieged by Lu Zhi. The brothers report here and are
             sent on to Yingchuan."))

    (place yingchuan
      (hanzi "潁川")
      (atlas-id yingchuan) (on-map? #t)
      (role "Huangfu Song and Zhu Jun face Zhang Liang and Zhang Bao here."))

    (place changshe
      (hanzi "長社")
      (atlas-id changshe) (on-map? #t)
      (role "Where the rebels camp in long grass and Huangfu Song burns them out. The
             actual site of the chapter's decisive battle."))

    (place luoyang
      (hanzi "洛陽")
      (atlas-id luoyang) (on-map? #t)
      (role "The capital. Named for the earthquake among the portents, and as the
             district where Cao Cao first held office."))

    (place wende-hall
      (hanzi "溫德殿")
      (atlas-id #f) (on-map? #f)
      (role "The hall where the black serpent drops onto the throne. Interior to the
             palace; not a map feature."))

    (place zhongshan
      (hanzi "中山")
      (atlas-id #f) (on-map? #f)
      (role "Home of the horse dealers Zhang Shiping and Su Shuang.")
      (editions
        (wikisource-zh "中山大商")
        (brewitt-en "They were from Changshan")
        (note "Brewitt-Taylor reads 常山 where both Chinese editions have 中山. A
               translation slip or a different recension; the Chinese is consistent.")))

    (place peiguo
      (hanzi "沛國")
      (atlas-id #f) (on-map? #f)
      (role "Cao Cao's origin, given at his introduction."))

    (place runan
      (hanzi "汝南")
      (atlas-id runan) (on-map? #t)
      (role "Home of Xu Shao, who gives Cao Cao his famous character reading."))

    (place nanyang
      (hanzi "南陽")
      (atlas-id wan) (on-map? #t)
      (role "Home of He Yong, who judges Cao Cao the man to restore peace.")))

  ;; -------------------------------------------------------------- characters

  (characters

    ;; -- the three brothers
    (character liu-bei
      (hanzi "劉備") (courtesy "玄德")
      (atlas-id liubei) (on-map? #t) (at zhuo)
      (age 28)
      (role "Mat-weaver and sandal-seller of Zhuo, descended from Liu Sheng, Prince
             Jing of Zhongshan. Reads the notice, sighs, and is overheard."))

    (character guan-yu
      (hanzi "關羽") (courtesy "雲長") (formerly "長生")
      (atlas-id guanyu) (on-map? #t) (at zhuo)
      (role "A fugitive from Hedong, five years on the run for killing a bully. Kills
             Cheng Yuanzhi at Daxing Shan."))

    (character zhang-fei
      (hanzi "張飛") (courtesy "翼德")
      (atlas-id zhangfei) (on-map? #t) (at zhuo)
      (role "Butcher, wine-seller and landowner at Zhuo. Owns the peach garden and
             funds the venture. Kills Deng Mao."))

    ;; -- the rising
    (character zhang-jue
      (hanzi "張角") (title "大賢良師" "天公將軍")
      (atlas-id zhangjue) (on-map? #t) (at guangzong)
      (role "Unclassed graduate of Julu turned healer. Receives the Book of Heaven,
             raises thirty-six circuits, and proclaims the rising."))

    (character zhang-bao
      (hanzi "張寶") (title "地公將軍")
      (atlas-id zhangbao) (on-map? #f) (at yingchuan)
      (role "Zhang Jue's brother. Camped at Changshe and burned out."))

    (character zhang-liang
      (hanzi "張梁") (title "人公將軍")
      (atlas-id zhangliang_yt) (on-map? #f) (at yingchuan)
      (role "Zhang Jue's brother. With Zhang Bao at Changshe."))

    (character nanhua-laoxian
      (hanzi "南華老仙")
      (atlas-id #f) (on-map? #f)
      (role "The immortal who gives Zhang Jue the three volumes of 太平要術 and warns
             him against turning from the way. Vanishes."))

    (character cheng-yuanzhi
      (hanzi "程遠志")
      (atlas-id chengyuanzhi) (on-map? #t) (at daxing-shan)
      (role "Rebel commander invading You province. Cut in two by Guan Yu — the first
             man the brothers kill."))

    (character deng-mao
      (hanzi "鄧茂")
      (atlas-id dengmao) (on-map? #t) (at daxing-shan)
      (role "Cheng Yuanzhi's subordinate. Speared through the heart by Zhang Fei."))

    (character ma-yuanyi
      (hanzi "馬元義")
      (atlas-id #f) (on-map? #f)
      (role "Zhang Jue's agent, sent to buy the eunuchs. Taken and executed when the
             plot is betrayed, forcing the rising early."))

    (character tang-zhou
      (hanzi "唐周")
      (atlas-id #f) (on-map? #f)
      (role "The follower who informs on the plot."))

    ;; -- the imperial side
    (character lu-zhi
      (hanzi "盧植") (courtesy "子幹")
      (atlas-id luzhi) (on-map? #t) (at guangzong)
      (role "Liu Bei's old teacher, commanding against Zhang Jue. Arrested mid-siege
             for refusing a eunuch's bribe."))

    (character huangfu-song
      (hanzi "皇甫嵩") (courtesy "義真")
      (atlas-id huangfusong) (on-map? #t) (at yingchuan)
      (role "Burns the rebel camp at Changshe."))

    (character zhu-jun
      (hanzi "朱儁") (courtesy "公偉")
      (atlas-id zhujun) (on-map? #t) (at yingchuan)
      (role "With Huangfu Song at Yingchuan.")
      (editions
        (note "Written 朱雋 in gutenberg_zh, 朱儁 in wikisource_zh. Same man; the
               verifier reports him absent from the Gutenberg text because of it.")))

    (character liu-yan
      (hanzi "劉焉")
      (atlas-id liuyan) (on-map? #t) (at youzhou)
      (role "Governor of You province, and an imperial kinsman — he greets Liu Bei as
             a relative. Issues the call for volunteers."))

    (character zou-jing
      (hanzi "鄒靖")
      (atlas-id zoujing) (on-map? #t) (at youzhou)
      (role "The commandant who advises raising volunteers, and leads with the
             brothers at Daxing Shan and Qingzhou."))

    (character gong-jing
      (hanzi "龔景")
      (atlas-id gongjing) (on-map? #f) (at qingzhou)
      (role "Governor of Qingzhou, besieged and relieved.")
      (editions
        (note "Named in both Chinese editions; Brewitt-Taylor renders him only as
               'the Prefect'.")))

    (character dong-zhuo
      (hanzi "董卓") (courtesy "仲穎")
      (atlas-id dongzhuo) (on-map? #t) (at guangzong)
      (role "Replaces the arrested Lu Zhi, is beaten by Zhang Jue, and is rescued by
             the three brothers — whom he then treats with contempt on learning they
             hold no office. The chapter ends on Zhang Fei wanting to kill him.")
      (note "The atlas now follows the text: he rides from Lintao to Guangzong within
             the chapter, and the closing scene is on the map."))

    (character cao-cao
      (hanzi "曹操") (courtesy "孟德") (childhood-name "阿瞞")
      (atlas-id caocao) (on-map? #t) (at yingchuan)
      (rank "騎都尉")
      (role "Introduced mid-chapter with a full biography: the feigned fit that
             discredits his uncle, the coloured cudgels at the gates of his district,
             and Xu Shao's verdict. Cuts up the rebels fleeing Changshe.")
      (note "The atlas now places him at Changshe, where the chapter actually brings
             him in with five thousand horse and foot."))

    (character cao-song
      (hanzi "曹嵩")
      (atlas-id #f) (on-map? #f)
      (role "Cao Cao's father, born to the Xiahou family and adopted by the eunuch
             Cao Teng — the detail that makes Cao Cao a eunuch's grandson."))

    (character he-jin
      (hanzi "何進") (courtesy "遂高")
      (atlas-id hejin) (on-map? #f)
      (role "General-in-Chief. Takes Ma Yuanyi, and memorialises for a general
             mobilisation against the rebels."))

    (character emperor-ling
      (hanzi "靈帝")
      (atlas-id #f) (on-map? #f)
      (role "The reigning emperor. Sees the serpent, receives the portents, and trusts
             the eunuchs."))

    (character zhang-rang
      (hanzi "張讓")
      (atlas-id #f) (on-map? #f)
      (role "Chief of the Ten Attendants; the emperor calls him 'Daddy'."))

    (character zuo-feng
      (hanzi "左豐")
      (atlas-id #f) (on-map? #f) (at guangzong)
      (role "The eunuch sent to inspect Lu Zhi, who demands a bribe and, refused,
             destroys him."))

    (character xu-shao
      (hanzi "許劭")
      (atlas-id #f) (on-map? #f) (at runan)
      (role "The judge of men who delivers the line the whole novel hangs on Cao Cao:
             治世之能臣，亂世之姦雄 — a capable minister in a peaceful age, a
             treacherous hero in a chaotic one. Cao Cao is delighted."))

    (character zhang-shiping
      (hanzi "張世平")
      (atlas-id #f) (on-map? #f) (at zhuo)
      (role "Horse dealer of Zhongshan. With Su Shuang, gives the brothers fifty
             horses, gold and silver, and a thousand catties of steel."))

    (character su-shuang
      (hanzi "蘇雙")
      (atlas-id #f) (on-map? #f) (at zhuo)
      (role "The other horse dealer.")))

  ;; ------------------------------------------------------------------ events
  ;;
  ;; In narrative order. `historicity` records the atlas's own judgement where it has
  ;; one, so the note and the map cannot drift apart silently.

  (events

    (event portents
      (sequence 1) (at wende-hall luoyang)
      (actors emperor-ling zhang-rang)
      (summary "A black serpent coils on the throne; earthquake and tidal wave at
                Luoyang; hens turn cock; black vapour and a rainbow in the halls. Cai
                Yong blames the eunuchs and is driven from court.")
      (on-map? #f))

    (event book-of-heaven
      (sequence 2) (at julu)
      (actors zhang-jue nanhua-laoxian)
      (summary "Gathering herbs, Zhang Jue meets an old man who leads him into a cave
                and gives him three volumes of the Way of Peace. He learns to summon
                wind and rain.")
      (on-map? #f))

    (event the-rising
      (sequence 3) (at julu)
      (actors zhang-jue zhang-bao zhang-liang)
      (summary "Plague spreads; Zhang Jue's charmed water makes his name. He organises
                thirty-six circuits under the slogan 蒼天已死，黃天當立, and the three
                brothers take the titles of the Dukes of Heaven, Earth and Humanity.")
      (on-map? partial)
      (note "The atlas shows this as Yellow Turban territory rather than as an event."))

    (event plot-betrayed
      (sequence 4)
      (actors ma-yuanyi tang-zhou he-jin)
      (summary "Ma Yuanyi is sent to buy the eunuchs; Tang Zhou informs; Ma Yuanyi is
                executed and the rising is forced into the open early.")
      (on-map? #f))

    (event three-commanders-sent
      (sequence 5)
      (actors lu-zhi huangfu-song zhu-jun he-jin)
      (summary "The court sends three armies out under Lu Zhi, Huangfu Song and Zhu
                Jun.")
      (on-map? #t))

    (event call-for-volunteers
      (sequence 6) (at youzhou zhuo)
      (actors liu-yan zou-jing)
      (summary "Zhang Jue's army enters You province. Liu Yan, on Zou Jing's advice,
                posts notices calling for volunteers. One goes up at Zhuo.")
      (on-map? partial))

    (event three-meet
      (sequence 7) (at zhuo)
      (actors liu-bei zhang-fei guan-yu)
      (summary "Liu Bei sighs at the notice; Zhang Fei challenges him for sighing and
                doing nothing; they go to drink, and Guan Yu comes in pushing a
                handcart, on his way to enlist.")
      (on-map? #t))

    (event peach-garden-oath
      (sequence 8) (at zhuo)
      (actors liu-bei guan-yu zhang-fei)
      (summary "In the peach orchard behind Zhang Fei's farm they sacrifice a black ox
                and a white horse and swear to seek not the same birthday but the same
                day of death. Three hundred villagers join them.")
      (historicity invented)
      (source-note "The histories say only that the three 'slept on the same mat and
                    were as brothers'. The oath is the novel's.")
      (on-map? #t))

    (event horses-and-steel
      (sequence 9) (at zhuo)
      (actors zhang-shiping su-shuang liu-bei)
      (summary "Two horse dealers of Zhongshan arrive, driven home early by the
                rising, and give fifty horses, gold and silver, and a thousand catties
                of steel. The three weapons are forged: the double swords, the
                Green Dragon blade, and the eighteen-foot serpent spear.")
      (on-map? #f))

    (event daxing-shan
      (sequence 10) (at daxing-shan)
      (actors liu-bei guan-yu zhang-fei zou-jing cheng-yuanzhi deng-mao)
      (summary "Five hundred men against a rebel host. Zhang Fei spears Deng Mao
                through the heart; Guan Yu cuts Cheng Yuanzhi in half. The rebels
                throw down their arms.")
      (on-map? #t))

    (event relief-of-qingzhou
      (sequence 11) (at qingzhou)
      (actors liu-bei guan-yu zhang-fei zou-jing gong-jing)
      (summary "Outnumbered, Liu Bei feigns retreat, draws the rebels over the hills,
                and takes them on three sides when the gongs sound. The siege lifts.")
      (on-map? #f))

    (event report-to-lu-zhi
      (sequence 12) (at guangzong)
      (actors liu-bei lu-zhi)
      (summary "The brothers part from Zou Jing and go to Liu Bei's old teacher, who
                is holding Zhang Jue but cannot break him. He sends them to Yingchuan
                with a thousand men to see how the other siege is going.")
      (on-map? #t))

    (event changshe-fire
      (sequence 13) (at changshe yingchuan)
      (actors huangfu-song zhu-jun zhang-liang zhang-bao)
      (summary "The rebels camp in deep grass. Every man cuts a bundle of dry grass;
                at the second watch, with a gale blowing, the camp is fired and the
                rebels break. The battle runs till dawn.")
      (on-map? #t))

    (event cao-cao-appears
      (sequence 14) (at changshe)
      (actors cao-cao zhang-liang zhang-bao)
      (summary "A troop under crimson banners cuts up the fleeing rebels. Its
                commander is Cao Cao, colonel of cavalry, arriving with five thousand
                horse and foot — introduced here with his whole biography.")
      (on-map? #t))

    (event lu-zhi-arrested
      (sequence 15)
      (actors lu-zhi zuo-feng dong-zhuo)
      (summary "Returning, the brothers meet a cage-cart on the road carrying Lu Zhi.
                A eunuch inspector demanded a bribe, was refused, and reported him for
                cowardice. Dong Zhuo has his command. Zhang Fei moves to free him and
                Liu Bei stops him.")
      (on-map? #f))

    (event rescue-of-dong-zhuo
      (sequence 16) (at guangzong)
      (actors liu-bei guan-yu zhang-fei dong-zhuo zhang-jue)
      (summary "Two days on, they find the imperial troops breaking under Zhang Jue's
                pursuit and charge into it, driving him back fifty li. Dong Zhuo asks
                what offices they hold; told none, he is openly contemptuous. Zhang Fei
                goes for his knife and is held back. The chapter ends there.")
      (on-map? #t))))
