;;; chapter-2.scm — 三國演義 第二回
;;;
;;; Structural reading of chapter 2. See chapter-1.scm for conventions.
;;;
;;; The chapter has two halves that barely touch: the mopping-up of the Yellow Turbans
;;; and Liu Bei's humiliating slide through the provincial bureaucracy, then a palace
;;; chapter in which the Emperor dies and the eunuch question turns lethal. The atlas
;;; shows the first half and almost none of the second, because the second happens
;;; entirely inside one building.

(chapter 2

  (title
    (chinese "張翼德怒鞭督郵　何國舅謀誅宦豎")
    (brewitt "An Official Is Thrashed; Uncle Ho Plots to Kill the Eunuchs")
    (atlas   "Zhang Fei Whips the Government Inspector; He Jin Plots to Kill the Eunuchs"))

  (year 184 189)
  (note "The chapter covers about five years, from the end of the rising to the death
         of Emperor Ling in the summer of 189.")

  ;; ------------------------------------------------------------------ places

  (places

    (place quyang
      (hanzi "曲陽")
      (atlas-id quyang) (on-map? #t)
      (role "Where Huangfu Song destroys Zhang Liang. Zhang Jue is already dead of
             illness; his coffin is opened and the corpse beheaded."))

    (place yangcheng
      (hanzi "陽城")
      (atlas-id yangcheng) (on-map? #t)
      (role "Zhang Bao fortifies here after his magic fails, and is killed by one of
             his own officers.")
      (note "Reappears in chapter 4 as the village Dong Zhuo's soldiers plunder during
             the festival."))

    (place wancheng
      (hanzi "宛城")
      (atlas-id wan) (on-map? #t)
      (role "Besieged by the last Yellow Turban remnant under Zhao Hong, Han Zhong and
             Sun Zhong. Zhu Jun and the brothers take it; Sun Jian arrives here and is
             first over the wall."))

    (place anxi
      (hanzi "安喜")
      (atlas-id anxi) (on-map? #t)
      (role "The county where Liu Bei is finally given a post — and where the inspector
             comes to extort him and Zhang Fei ties him to a post."))

    (place daizhou
      (hanzi "代州")
      (atlas-id daizhou) (on-map? #t)
      (role "Where the brothers hide with Liu Hui after the flogging, until the warrant
             is lifted."))

    (place yuyang
      (hanzi "漁陽")
      (atlas-id yuyang) (on-map? #t)
      (role "Zhang Ju and Zhang Chun's rebellion, put down by Liu Yu with Liu Bei's
             help — the service that earns Liu Bei his pardon and Pingyuan."))

    (place pingyuan
      (hanzi "平原")
      (atlas-id pingyuan) (on-map? #t)
      (role "Liu Bei's reward at the chapter's end, and the most settled posting he has
             held. The atlas shows him here for the rest of the early chapters."))

    (place changsha
      (hanzi "長沙")
      (atlas-id changsha) (on-map? #t)
      (role "Ou Xing's rising; Sun Jian is made governor, suppresses it in under two
             months, and is ennobled Marquis of Wucheng."))

    (place lintao
      (hanzi "臨洮")
      (atlas-id lintao) (on-map? #t)
      (role "Dong Zhuo's birthplace in the far west, given at the head of the chapter.")
      (note "The atlas pins Dong Zhuo at Jicheng in Liang province, which is the same
             general country and a reasonable stand-in."))

    (place hejian
      (hanzi "河間")
      (atlas-id hejian) (on-map? #t)
      (role "Where the Dowager Dong is exiled, and shortly afterwards murdered.")))

  ;; -------------------------------------------------------------- characters

  (characters

    (character liu-bei
      (hanzi "劉備") (courtesy "玄德")
      (atlas-id liubei) (on-map? #t) (at pingyuan)
      (role "Fights through the last of the rising, is passed over for reward, is given
             a county, is extorted, and walks away from the post rather than pay. Ends
             the chapter restored and at Pingyuan."))

    (character guan-yu
      (hanzi "關羽") (courtesy "雲長")
      (atlas-id guanyu) (on-map? #t) (at pingyuan)
      (role "Counsels leaving Anxi: 'a thorn bush is no place for a phoenix.'"))

    (character zhang-fei
      (hanzi "張飛") (courtesy "翼德")
      (atlas-id zhangfei) (on-map? #t) (at pingyuan)
      (role "Drunk and grieving, finds the elders weeping at the inspector's gate, drags
             him out by the hair, ties him to a hitching post and flogs him with a
             willow switch until the switch is too short to swing."))

    (character du-you
      (hanzi "督郵")
      (atlas-id #f) (on-map? #f) (at anxi)
      (role "The inspector. Unnamed throughout — he is an office, not a person, which
             is part of the point."))

    (character zhang-bao
      (hanzi "張寶")
      (atlas-id zhangbao) (on-map? #t) (at yangcheng)
      (role "Looses his hair and calls down a storm of phantom cavalry; Zhu Jun breaks
             the spell with the blood of pigs, goats and dogs poured from the cliffs.
             Killed by his own officer."))

    (character zhang-liang
      (hanzi "張梁")
      (atlas-id zhangliang_yt) (on-map? #t) (at quyang)
      (role "Destroyed by Huangfu Song at Quyang."))

    (character zhu-jun
      (hanzi "朱儁") (courtesy "公偉")
      (atlas-id zhujun) (on-map? #t) (at wancheng)
      (role "Commands the southern mopping-up. Argues against accepting surrender —
             and is talked round by Liu Bei, whose argument is the better one and
             works."))

    (character huangfu-song
      (hanzi "皇甫嵩") (courtesy "義真")
      (atlas-id huangfusong) (on-map? #t) (at quyang)
      (role "Wins seven battles running, takes Dong Zhuo's command, and uses his first
             act in power to get Lu Zhi restored."))

    (character sun-jian
      (hanzi "孫堅") (courtesy "文台")
      (atlas-id sunjian) (on-map? #t) (at wancheng changsha)
      (role "Introduced here. At seventeen he scattered a party of pirates on the
             Qiantang by pretending to signal troops that were not there. First man
             over the wall at Wancheng; then governor of Changsha."))

    (character zhao-hong
      (hanzi "趙弘") (atlas-id #f) (on-map? #f) (at wancheng))
    (character han-zhong
      (hanzi "韓忠") (atlas-id #f) (on-map? #f) (at wancheng))
    (character sun-zhong
      (hanzi "孫仲") (atlas-id #f) (on-map? #f) (at wancheng)
      (role "The three remnant leaders calling themselves Zhang Jue's avengers. Sun
             Zhong is shot off his horse by Liu Bei."))

    (character gao-sheng
      (hanzi "高昇") (atlas-id gaosheng) (on-map? #t) (at yangcheng)
      (role "Zhang Bao's subordinate, unhorsed by Zhang Fei."))

    (character liu-yu
      (hanzi "劉虞")
      (atlas-id liuyu) (on-map? #t) (at yuyang)
      (role "Governor sent against the Yuyang rebellion; takes Liu Bei on recommendation
             and reports his services, which lifts the warrant."))

    (character zhang-jun
      (hanzi "張鈞")
      (atlas-id #f) (on-map? #f)
      (role "The court official who hears Liu Bei's grievance and tells the Emperor the
             rising happened because the eunuchs sold offices. Thrown out for it."))

    (character liu-tao
      (hanzi "劉陶") (atlas-id #f) (on-map? #f))
    (character chen-dan
      (hanzi "陳耽") (atlas-id #f) (on-map? #f)
      (role "Two ministers who tell Emperor Ling the truth about the Ten and are
             killed for it — Chen Dan murdered in prison the same night."))

    (character he-jin
      (hanzi "何進") (courtesy "遂高")
      (atlas-id hejin) (on-map? #t) (at luoyang)
      (role "Butcher's son raised by his sister's place in the harem. Warned away from
             the palace gate, survives the first attempt, and ends the chapter having
             ignored two men who told him not to summon the provincial armies."))

    (character he-taihou
      (hanzi "何后")
      (atlas-id #f) (on-map? #f)
      (role "He Jin's sister, Empress and then Dowager. Poisoned the Lady Wang out of
             jealousy; protects the eunuchs because she owes them her position; twice
             stops her brother from acting."))

    (character dong-taihou
      (hanzi "董太后")
      (atlas-id #f) (on-map? #f)
      (role "Emperor Ling's mother, who wants Xie on the throne. Loses the quarrel at
             the banquet, is exiled to Hejian, and is murdered there a few months
             later on He Jin's orders."))

    (character emperor-ling
      (hanzi "靈帝") (atlas-id #f) (on-map? #f)
      (role "Dies in the summer of 189, leaving the succession unsettled."))

    (character liu-bian
      (hanzi "劉辯")
      (atlas-id #f) (on-map? #f)
      (role "He Taihou's son, put on the throne — briefly."))

    (character liu-xie
      (hanzi "劉協")
      (atlas-id emperorxian) (on-map? #f)
      (role "Son of the murdered Lady Wang, raised by the Dowager Dong. The eunuchs
             enter his name on the roll instead. He is nine.")
      (note "The atlas does not pin him until chapter 3."))

    (character jian-shuo
      (hanzi "蹇碩")
      (atlas-id #f) (on-map? #f)
      (role "The eunuch who advises killing He Jin. Hunted through the palace garden
             and murdered by one of his own."))

    (character yuan-shao
      (hanzi "袁紹") (courtesy "本初")
      (atlas-id yuanshao) (on-map? #t) (at luoyang)
      (role "Offers to break into the palace and finish all of them. Right, and
             ignored — twice."))

    (character cao-cao
      (hanzi "曹操") (courtesy "孟德")
      (atlas-id caocao) (on-map? #t) (at luoyang)
      (role "Warns that the eunuch influence is fifty years deep and that the plot must
             stay secret. He Jin: 'What do inferiors like you know of government?'"))

    (character he-miao
      (hanzi "何苗") (atlas-id #f) (on-map? #f)
      (role "He Jin's younger brother, bought by the eunuchs, who argues his sister
             round each time."))

    (character chen-lin
      (hanzi "陳琳") (courtesy "孔璋")
      (atlas-id chenlin) (on-map? #t) (at luoyang)
      (role "Tells He Jin that summoning armies to the capital is 'to cover the eyes and
             snatch at swallows'. Called a bookworm for it.")))

  ;; ------------------------------------------------------------------ events

  (events

    (event zhang-bao-magic
      (sequence 1) (at yangcheng)
      (actors zhang-bao zhu-jun liu-bei zhang-fei guan-yu gao-sheng)
      (summary "Zhang Bao raises a black cloud full of phantom horse and foot and the
                imperial troops break. Zhu Jun answers it with the blood of slaughtered
                swine, goats and dogs poured from the cliffs; the phantom army falls to
                earth like torn paper.")
      (on-map? #f))

    (event end-of-the-brothers
      (sequence 2) (at quyang yangcheng)
      (actors huangfu-song zhang-liang zhang-bao)
      (summary "Zhang Jue dies of illness before Huangfu Song arrives; his coffin is
                opened and the corpse beheaded, the head sent to the capital. Zhang
                Liang is killed at Quyang, Zhang Bao by one of his own officers.")
      (on-map? partial)
      (note "The atlas shows Yellow Turban territory shrinking but pins none of this."))

    (event wancheng
      (sequence 3) (at wancheng)
      (actors zhu-jun liu-bei sun-jian han-zhong zhao-hong sun-zhong)
      (summary "Zhu Jun refuses the rebels' surrender on principle; Liu Bei argues that
                a cornered army fights to the death and that a corner should be left
                open. It works. Sun Jian arrives from the east and is first over the
                wall, killing a score of men by hand.")
      (on-map? partial))

    (event rewards-withheld
      (sequence 4)
      (actors liu-bei zhang-jun sun-jian)
      (summary "Sun Jian has friends at court and is placed at once. Liu Bei, with a
                memorial in his favour, waits and gets nothing. Zhang Jun raises it at
                court and is thrown out; the eunuchs then hand out minor posts to head
                off resentment, and Liu Bei is made magistrate of Anxi.")
      (on-map? #f))

    (event flogging-the-inspector
      (sequence 5) (at anxi)
      (actors zhang-fei liu-bei guan-yu du-you)
      (summary "The inspector arrives, refuses to return Liu Bei's salute, calls his
                descent a lie, and works up false testimony against him to extract a
                bribe. Zhang Fei, drunk, finds the village elders weeping at the gate,
                drags him out by the hair, ties him to a post and flogs him with a
                willow switch. Liu Bei hangs the official seal round the man's neck
                and the three walk away.")
      (historicity relocated)
      (source-note "The histories give the flogging to Liu Bei himself. The novel moves
                    it to Zhang Fei, which protects Liu Bei's character and costs the
                    scene nothing.")
      (on-map? #t))

    (event yuyang
      (sequence 6) (at yuyang)
      (actors liu-bei liu-yu)
      (summary "Zhang Ju and Zhang Chun rebel at Yuyang. Liu Bei is recommended to Liu
                Yu, breaks the rebels, and Zhang Chun is killed by his own men. The
                service earns a pardon for the flogging and, eventually, Pingyuan.")
      (on-map? #f))

    (event death-of-emperor-ling
      (sequence 7)
      (actors emperor-ling he-jin he-taihou dong-taihou jian-shuo)
      (summary "The Emperor dies in the summer of 189. The eunuchs conceal it and forge
                a summons to bring He Jin in and kill him; he is warned at the gate.
                Yuan Shao escorts him in with five companies and Liu Bian is put on the
                throne over the coffin. Jian Shuo is run down in the palace garden.")
      (on-map? partial))

    (event two-dowagers
      (sequence 8) (at hejian)
      (actors he-taihou dong-taihou zhang-rang he-jin)
      (summary "The two Dowagers quarrel at a banquet — 'you low-born daughter of a
                butcher' — and He Taihou wins. The Dowager Dong is removed to Hejian
                and murdered there; her brother takes his own life. He Jin feigns
                illness and does not attend the funeral.")
      (on-map? #f))

    (event summon-the-armies
      (sequence 9) (at luoyang)
      (actors he-jin yuan-shao chen-lin cao-cao)
      (summary "Yuan Shao urges calling up the provincial armies. Chen Lin warns that
                gathering armed men each with his own designs is turning the weapon on
                oneself. Cao Cao says a single gaoler would do. He Jin calls him an
                inferior and sends the letters.")
      (historicity historical)
      (source-note "The decision that lets Dong Zhuo into the capital, and both warnings
                    are in the histories.")
      (on-map? partial))))
