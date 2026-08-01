;;; chapter-4.scm — 三國演義 第四回
;;;
;;; Structural reading of chapter 4. See chapter-1.scm for conventions.
;;;
;;; Two movements. First the deposition and the murder of the deposed — a boy emperor,
;;; his mother and a lady-in-waiting killed in an upper room, which the novel gives
;;; three poems to. Then Cao Cao's failed assassination and his flight east, ending in
;;; the killing at Lü Boshe's farm and the line the whole character is built on.

(chapter 4

  (title
    (chinese "廢漢帝陳留踐位　謀董賊孟德獻刀")
    (brewitt "The Deposition of the Emperor: Prince of Chʻên-liu Becomes Emperor; Schemes Against Tung Cho: Mêng-tê Presents a Sword")
    (atlas   "Deposing the Emperor, Dong Zhuo Installs Another; Cao Cao Presents a Sword and Flees"))

  (year 189 190)

  ;; ------------------------------------------------------------------ places

  (places

    (place luoyang
      (hanzi "洛陽")
      (atlas-id luoyang) (on-map? #t)
      (role "The deposition, the murders, and the attempt on Dong Zhuo."))

    (place yongan-palace
      (hanzi "永安宮")
      (atlas-id #f) (on-map? #f)
      (role "Where the deposed emperor, his mother and the Lady Tang are shut up with
             their supplies dwindling, and where Li Ru kills all three."))

    (place bohai
      (hanzi "渤海")
      (atlas-id nanpi) (on-map? #t)
      (role "The command Dong Zhuo gives Yuan Shao to buy him off after he walks out —
             on the advice that the Yuan family has had four generations of favour and
             clients everywhere. From here Yuan Shao writes to Wang Yun.")
      (note "The atlas uses `nanpi`, the commandery seat, and labels it 渤海."))

    (place yangcheng
      (hanzi "陽城")
      (atlas-id #f) (on-map? #f)
      (role "The village Dong Zhuo's soldiers surround during the annual festival. They
             take the heads of the men, burn them under the walls at Luoyang as proof of
             a victory over rebels, and divide the women and jewellery.")
      (gap "Not in the gazetteer. It is the clearest single statement of what Dong
            Zhuo's rule actually was."))

    (place zhongmou
      (hanzi "中牟")
      (atlas-id #f) (on-map? #f)
      (role "Where Cao Cao, fleeing east, is recognised at the gate and taken to the
             magistrate — who turns out to be Chen Gong.")
      (gap "Not in the gazetteer, though it is where Chen Gong joins the story."))

    (place chenggao
      (hanzi "成皋")
      (atlas-id #f) (on-map? #f)
      (role "Lü Boshe's farm, three days east of Zhongmou.")
      (note "The atlas places the Lü Boshe killing at Pengcheng, which is far too far
             east — a placeholder rather than a reading of the text."))

    (place qiaojun
      (hanzi "譙郡")
      (atlas-id #f) (on-map? #f)
      (role "Cao Cao's home, which he is making for.")))

  ;; -------------------------------------------------------------- characters

  (characters

    (character dong-zhuo
      (hanzi "董卓") (courtesy "仲穎")
      (atlas-id dongzhuo) (on-map? #t) (at luoyang)
      (role "Deposes the emperor, installs a nine-year-old, and behaves thereafter as
             though the palace were his house: sleeps there, defiles the women of it,
             lies on the imperial couch, comes to court booted and armed and does not
             announce his name."))

    (character li-ru
      (hanzi "李儒")
      (atlas-id #f) (on-map? #f) (at luoyang yongan-palace)
      (role "Reads out the deposition. Then takes ten men to the Yongan Palace with a
             cup of poisoned wine, throws the Empress out of a window, has the Lady Tang
             strangled and forces the wine on the boy.")
      (gap "Still absent from the atlas roster, and he does the chapter's worst thing."))

    (character liu-bian
      (hanzi "劉辯") (title "弘農王")
      (atlas-id #f) (on-map? #f) (at yongan-palace)
      (role "Deposed after less than half a year, made Prince of Hongnong, and murdered
             for writing a poem about swallows that Dong Zhuo chose to read as
             resentment."))

    (character he-taihou
      (hanzi "何后")
      (atlas-id #f) (on-map? #f) (at yongan-palace)
      (role "Stripped of her robes at the deposition; killed with her son. Rails at her
             dead brother as the author of it all."))

    (character lady-tang
      (hanzi "唐妃")
      (atlas-id #f) (on-map? #f) (at yongan-palace)
      (role "Offers to drink in her lord's place and is refused — 'and who may you be
             to die for a prince?' Strangled. The novel gives her the last of the three
             poems."))

    (character liu-xie
      (hanzi "劉協") (title "獻帝")
      (atlas-id emperorxian) (on-map? #t) (at luoyang)
      (role "Put on the throne at nine, reign-style Chuping. Everything he will do for
             the next eighty chapters is done to him."))

    (character ding-guan
      (hanzi "丁管")
      (atlas-id #f) (on-map? #f) (at luoyang)
      (role "The one official who rushes at Dong Zhuo with his ivory baton during the
             deposition. Taken out and killed, railing to the end."))

    (character yuan-shao
      (hanzi "袁紹") (courtesy "本初")
      (atlas-id yuanshao) (on-map? #f) (at bohai)
      (role "Hangs his seal of office at the east gate and leaves. Bought off with
             Bohai, from where he writes urging Wang Yun to act.")
      (gap "Not pinned in the atlas for this chapter, though the letter he sends from
            Bohai is what starts Wang Yun moving."))

    (character yuan-wei
      (hanzi "袁隗")
      (atlas-id #f) (on-map? #f) (at luoyang)
      (role "Yuan Shao's uncle, still in office, and the reason Dong Zhuo tolerates the
             walkout. Killed with his whole household in chapter 5."))

    (character wu-fu
      (hanzi "伍孚")
      (atlas-id #f) (on-map? #f) (at luoyang)
      (role "Wears a breastplate under his court dress and a dagger inside it for days,
             then tries Dong Zhuo on the steps. Dong Zhuo is too strong for him and Lü
             Bu finishes it. 'You are not my prince, I am not your minister: where is
             the rebellion?' Hacked to pieces.")
      (note "The novel gives him a eulogy. The atlas has neither him nor the attempt."))

    (character wang-yun
      (hanzi "王允") (courtesy "子師")
      (atlas-id wangyun) (on-map? #t) (at luoyang)
      (role "Calls his colleagues to a false birthday party so the gathering will not be
             suspicious, and weeps at his own table. Lends Cao Cao the seven-star sword.
             The first move of a plan that takes until chapter 9."))

    (character cao-cao
      (hanzi "曹操") (courtesy "孟德")
      (atlas-id caocao) (on-map? #t) (at luoyang zhongmou chenggao)
      (role "Laughs at the weeping ministers, borrows the sword, and gets close enough —
             then loses the moment when Dong Zhuo, too fat to sit long, rolls over and
             catches his reflection in a mirror. Presents the sword as a gift instead,
             takes a horse to try, and rides east."))

    (character chen-gong
      (hanzi "陳宮") (courtesy "公台")
      (atlas-id chengong) (on-map? #t) (at zhongmou chenggao)
      (role "Magistrate of Zhongmou. Recognises Cao Cao, questions him at midnight,
             is moved by the answer, abandons his office and rides with him — and leaves
             him three days later over the killing at the farm."))

    (character lv-boshe
      (hanzi "呂伯奢")
      (atlas-id lvboshe) (on-map? #t) (at chenggao)
      (role "Cao Cao's father's sworn brother. Takes them in, goes to the village for
             wine because there is none in the house, and is cut down on the road coming
             back with two jars and fruit and vegetables."))

    (character lv-bu
      (hanzi "呂布") (courtesy "奉先")
      (atlas-id lvbu) (on-map? #t) (at luoyang)
      (role "Present at the assassination attempt and sent out for a horse at exactly
             the wrong moment; kills Wu Fu.")))

  ;; ------------------------------------------------------------------ events

  (events

    (event yuan-shao-bought-off
      (sequence 1) (at luoyang bohai)
      (actors yuan-shao dong-zhuo yuan-wei)
      (summary "Yuan Shao hangs up his seal and goes. Dong Zhuo is advised not to pursue
                it: four generations of Yuan favour means clients everywhere and a
                rising in Shandong. He is given Bohai instead.")
      (on-map? partial))

    (event the-deposition
      (sequence 2) (at luoyang)
      (actors dong-zhuo li-ru liu-bian liu-xie he-taihou ding-guan)
      (summary "In the ninth month the court is assembled in the Hall of Abounding
                Virtue. Li Ru reads the document; the Emperor is led down, his seal
                removed, and made to kneel facing north and call himself minister. Ding
                Guan rushes at Dong Zhuo with his baton and is killed. The Prince of
                Chenliu takes the throne at nine.")
      (historicity historical)
      (on-map? #t))

    (event murder-in-yongan
      (sequence 3) (at yongan-palace)
      (actors li-ru liu-bian he-taihou lady-tang)
      (summary "Rations dwindle; the boy writes a poem about swallows and the spring
                grass; a spy carries it to Dong Zhuo, who takes it as resentment and a
                sufficient excuse. Li Ru brings poisoned wine and offers a choice of
                daggers and cords. All three sing before they die.")
      (historicity historical)
      (source-note "The killing of the deposed emperor and his mother is in the record.
                    The poems are the novel's.")
      (on-map? #f)
      (gap "Nothing on the map marks it."))

    (event yangcheng-festival
      (sequence 4) (at yangcheng)
      (actors dong-zhuo)
      (summary "Dong Zhuo takes soldiers out to a village festival, surrounds it,
                plunders it, and comes back with cartloads of booty, women prisoners and
                a great many heads — which are burned beneath the walls as trophies of a
                victory over rebels.")
      (on-map? #f))

    (event wu-fu-attempt
      (sequence 5) (at luoyang)
      (actors wu-fu dong-zhuo lv-bu)
      (summary "Wu Fu, who has been wearing armour and a dagger under his court dress
                waiting for a chance, strikes on the steps and fails. Dong Zhuo holds
                him off until Lü Bu arrives.")
      (on-map? #f))

    (event birthday-that-was-not
      (sequence 6) (at luoyang)
      (actors wang-yun cao-cao yuan-shao)
      (summary "Yuan Shao's letter reaches Wang Yun, who can see no opening. He invites
                his colleagues to a birthday party that is not his birthday, and weeps
                at the table. Cao Cao laughs, offers to do it himself, and asks for the
                seven-star sword.")
      (on-map? #t))

    (event the-sword-and-the-mirror
      (sequence 7) (at luoyang)
      (actors cao-cao dong-zhuo lv-bu li-ru)
      (summary "Cao Cao comes late, is asked why, and is sent a horse for the trouble.
                Dong Zhuo rolls over to lie down; Cao Cao grips the sword; Dong Zhuo
                sees him in the mirror and turns. Cao Cao drops to his knees and
                presents the blade as a gift. He asks to try the horse and rides out of
                the eastern gate at speed. Li Ru works it out within the hour.")
      (historicity invented)
      (source-note "The sword and the mirror are the novel's. Cao Cao's flight from
                    Dong Zhuo's service is historical.")
      (on-map? #t))

    (event zhongmou
      (sequence 8) (at zhongmou)
      (actors cao-cao chen-gong)
      (summary "Taken at the gate and brought before the magistrate, Cao Cao gives a
                false name and is recognised anyway. At midnight Chen Gong has him
                brought in privately, asks why he did it, hears the answer, unties him,
                and resigns his office to follow him.")
      (on-map? partial)
      (gap "Zhongmou is not in the gazetteer; the atlas puts this at Pengcheng."))

    (event lv-boshe
      (sequence 9) (at chenggao)
      (actors cao-cao chen-gong lv-boshe)
      (summary "Three days on they stop at the farm of Cao Cao's father's sworn brother.
                Their host goes to the village for wine. They hear a knife being
                sharpened and a voice say 'bind before killing' — and kill the whole
                household, eight people, before finding the pig tied up in the kitchen.
                Riding away they meet Lü Boshe coming back with the wine, and Cao Cao
                cuts him down too, deliberately, because a man who found his family dead
                would raise the country.")
      (historicity historical-in-substance)
      (source-note "Even sources sympathetic to Cao Cao record a version of the killing
                    at Lü Boshe's house. The second killing on the road, and the line
                    that follows, are the novel's.")
      (on-map? #t))

    (event i-would-rather-betray
      (sequence 10) (at chenggao)
      (actors cao-cao chen-gong)
      (summary "Chen Gong says that to kill deliberately is very wrong. Cao Cao: 寧教我
                負天下人，休教天下人負我 — better that I betray the world than the world
                betray me. That night Chen Gong lies awake deciding whether to kill him,
                and in the morning rides away instead.")
      (on-map? #t)
      (note "The line is the hinge of the whole characterisation, and the atlas records
             it only as a note on a pin."))))
