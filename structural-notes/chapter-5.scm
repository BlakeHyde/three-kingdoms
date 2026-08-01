;;; chapter-5.scm — 三國演義 第五回
;;;
;;; Structural reading of chapter 5. See chapter-1.scm for conventions.
;;;
;;; The first chapter with a real map in it. Seventeen lords bring armies from
;;; everywhere in the empire to two passes east of Luoyang, and most of the cast of the
;;; next hundred chapters is on the board at once. It is also the chapter with the
;;; largest gap between what happens and what the histories record: both of its famous
;;; set-pieces are invented.

(chapter 5

  (title
    (chinese "發矯詔諸鎮應曹公　破關兵三英戰呂布")
    (brewitt "Sending Out the Call: Many Respond; Destroying an Army: The Three Brothers Fight Against Lü Pu")
    (atlas   "Cao Cao Rallies the Lords; Three Heroes Fight Lü Bu at Hulao Pass"))

  (year 190)

  ;; ------------------------------------------------------------------ places

  (places

    (place chenliu
      (hanzi "陳留")
      (atlas-id chenliu) (on-map? #t)
      (role "Cao Cao's home country, where he sells the family property, is bankrolled
             by Wei Hong, and raises the volunteer corps under a white banner reading
             忠義 — Loyalty and Right."))

    (place sishui-pass
      (hanzi "汜水關")
      (atlas-id sishui) (on-map? #t)
      (role "The first pass. Hua Xiong holds it; Bao Zhong and Sun Jian are both broken
             against it; Guan Yu kills Hua Xiong before it."))

    (place hulao-pass
      (hanzi "虎牢關")
      (atlas-id hulao) (on-map? #t)
      (role "Fifty li from Luoyang. Dong Zhuo brings fifteen legions here himself and
             puts Lü Bu in a stockade outside it. The three brothers fight Lü Bu here.")
      (note "Historically Sishui and Hulao are the same place. The novel makes them two
             and fights a separate battle at each; the atlas follows the novel and says
             so in the gazetteer entry."))

    (place liangdong
      (hanzi "梁東")
      (atlas-id liangdong) (on-map? #t)
      (role "Where Sun Jian falls back and camps after the stones drive him off the
             pass, and where he is attacked at midnight and burnt out."))

    (place pingyuan
      (hanzi "平原")
      (atlas-id pingyuan) (on-map? #t)
      (role "Gongsun Zan passes through on his way west and finds Liu Bei there under a
             yellow flag among the mulberry trees. The three brothers join his column
             from here."))

    (place luoyang
      (hanzi "洛陽")
      (atlas-id luoyang) (on-map? #t)
      (role "Dong Zhuo's seat. Yuan Wei's household is killed here and the head hung
             outside the gate.")))

  ;; -------------------------------------------------------------- characters
  ;;
  ;; The seventeen lords are listed as a block: most of them do nothing here, but the
  ;; roll-call is the point — it is the map of who holds what in 190.

  (characters

    (character cao-cao
      (hanzi "曹操") (courtesy "孟德")
      (atlas-id caocao) (on-map? #t) (at chenliu)
      (role "Issues the forged decree and the manifesto, and is the chapter's only
             consistently sensible voice: he proposes Yuan Shao as chief, defends Guan
             Yu's right to fight, and sends the three brothers meat and wine afterwards
             when the lords have finished insulting them."))

    (character wei-hong
      (hanzi "衛弘")
      (atlas-id weihong) (on-map? #t) (at chenliu)
      (role "The rich graduate who funds the whole thing — 'careless of wealth but
             careful of virtue'. Without him there is no confederacy."))

    (character yuan-shao
      (hanzi "袁紹") (courtesy "本初")
      (atlas-id yuanshao) (on-map? #t) (at sishui-pass)
      (role "Elected oath-chief on a three-storeyed altar and immediately proves the
             wrong choice: he wishes aloud for Yan Liang and Wen Chou instead of using
             the man in front of him, and lets his brother insult a volunteer."))

    (character yuan-shu
      (hanzi "袁術") (courtesy "公路")
      (atlas-id yuanshu) (on-map? #t) (at sishui-pass)
      (role "Made Chief of Commissariat, and withholds Sun Jian's grain on the argument
             that a victorious Sun Jian would only replace a wolf with a tiger. Then
             demands Guan Yu be expelled from the tent for presuming.")
      (note "Both of the confederacy's failures are his doing, and both are motivated by
             rank rather than strategy."))

    (character sun-jian
      (hanzi "孫堅") (courtesy "文台")
      (atlas-id sunjian) (on-map? #t) (at sishui-pass liangdong)
      (role "Volunteers as van-leader. Kills Hu Zhen's officer, is driven off by stones,
             is starved by Yuan Shu, and is burnt out at midnight — escaping only
             because Zu Mao takes his purple turban."))

    (character zu-mao
      (hanzi "祖茂")
      (atlas-id zumao) (on-map? #t) (at liangdong)
      (role "Wears his lord's conspicuous purple turban to draw the pursuit, hangs it on
             a burnt post, hides in the wood, and rushes out with both swords when they
             close on it. Killed by Hua Xiong."))

    (character cheng-pu (hanzi "程普") (atlas-id chengpu) (on-map? #t) (at sishui-pass))
    (character huang-gai (hanzi "黃蓋") (atlas-id huanggai) (on-map? #f) (at sishui-pass))
    (character han-dang (hanzi "韓當") (atlas-id handang) (on-map? #t) (at sishui-pass)
      (role "Sun Jian's four captains, introduced here by name and weapon. Huang Gai is
             in the atlas roster; Cheng Pu and Han Dang are not."))

    (character hua-xiong
      (hanzi "華雄")
      (atlas-id huaxiong) (on-map? #t) (at sishui-pass)
      (role "Volunteers over Lü Bu's head — 'a butcher's knife to kill a chicken'. Kills
             Bao Zhong, Zu Mao, Yu She and Pan Feng, and is killed by Guan Yu in the
             time it takes wine to cool."))

    (character guan-yu
      (hanzi "關羽") (courtesy "雲長")
      (atlas-id guanyu) (on-map? #t) (at sishui-pass hulao-pass)
      (role "A mounted archer in a minor magistrate's train. Offers his head as forfeit,
             refuses the stirrup cup until he comes back, and returns with Hua Xiong's
             head while the wine is still warm."))

    (character liu-bei
      (hanzi "劉備") (courtesy "玄德")
      (atlas-id liubei) (on-map? #t) (at pingyuan hulao-pass)
      (role "Seated last in the line of lords, and only because Yuan Shao respects the
             imperial surname. Joins the fight at Hulao as the third blade."))

    (character zhang-fei
      (hanzi "張飛") (courtesy "翼德")
      (atlas-id zhangfei) (on-map? #t) (at hulao-pass)
      (role "Rides in to save Gongsun Zan with Red Hare already at his back — 'Stay, O
             thrice-named slave!' Fights Lü Bu fifty bouts alone."))

    (character lv-bu
      (hanzi "呂布") (courtesy "奉先")
      (atlas-id lvbu) (on-map? #t) (at hulao-pass)
      (role "Kills Fang Yue, Mu Shun, and breaks Wu Anguo's wrist; drives Gongsun Zan
             off. Fights all three brothers at once and disengages by feinting at Liu
             Bei to open an angle. Not beaten — extracted."))

    (character gongsun-zan
      (hanzi "公孫瓚") (courtesy "伯珪")
      (atlas-id gongsunzan) (on-map? #t) (at pingyuan hulao-pass)
      (role "Collects the brothers on the road and vouches for them at the council.
             'Thus are able men buried!' Nearly killed by Lü Bu."))

    (character dong-zhuo
      (hanzi "董卓") (courtesy "仲穎")
      (atlas-id dongzhuo) (on-map? #t) (at luoyang hulao-pass)
      (role "Sends Li Jue and Guo Si to exterminate Yuan Wei's household, then takes
             fifteen legions to Hulao himself."))

    (character li-jue (hanzi "李傕") (atlas-id lijue) (on-map? #t) (at sishui-pass))
    (character guo-si (hanzi "郭汜") (atlas-id guosi) (on-map? #t) (at sishui-pass)
      (role "Kill Yuan Wei's household, then hold Sishui with five legions under orders
             not to give battle unnecessarily."))

    (character xiahou-dun
      (hanzi "夏侯惇") (courtesy "元讓")
      (atlas-id xiahoudun) (on-map? #t) (at chenliu)
      (role "Comes in with his brother and a company each. Killed a man at fourteen for
             insulting his teacher and had been a fugitive since."))

    (character xiahou-yuan (hanzi "夏侯淵") (atlas-id xiahouyuan) (on-map? #f) (at chenliu))
    (character cao-ren (hanzi "曹仁") (atlas-id caoren) (on-map? #f) (at chenliu))
    (character cao-hong (hanzi "曹洪") (atlas-id caohong) (on-map? #f) (at chenliu))
    (character yue-jin (hanzi "樂進") (courtesy "文謙") (atlas-id lejin) (on-map? #f) (at chenliu))
    (character li-dian (hanzi "李典") (courtesy "曼成") (atlas-id lidian) (on-map? #f) (at chenliu)
      (role "The founding staff, all arriving at Chenliu within days of the call. Four
             of the six are in the atlas roster; none is pinned before much later.")
      (note "This is where the Wei command structure is assembled, and the atlas shows
             none of it."))

    (character the-seventeen-lords
      (kind roll-call)
      (atlas-id #f)
      (members
        ("南陽" 袁術) ("冀州" 韓馥) ("豫州" 孔伷) ("兗州" 劉岱) ("河內" 王匡)
        ("陳留" 張邈) ("東郡" 喬瑁) ("山陽" 袁遺) ("濟北" 鮑信) ("北海" 孔融)
        ("廣陵" 張超) ("徐州" 陶謙) ("西涼" 馬騰) ("北平" 公孫瓚) ("上黨" 張楊)
        ("長沙" 孫堅) ("渤海" 袁紹))
      (note "The roll-call doubles as a snapshot of who holds what in 190, and several
             of these men — Han Fu, Liu Dai, Tao Qian, Ma Teng, Kong Rong — become
             factions in the atlas within ten chapters.")))

  ;; ------------------------------------------------------------------ events

  (events

    (event raising-the-corps
      (sequence 1) (at chenliu)
      (actors cao-cao wei-hong xiahou-dun xiahou-yuan cao-ren cao-hong yue-jin li-dian)
      (summary "Cao Cao reaches home, sells what there is, and is funded by Wei Hong.
                The white banner goes up and volunteers arrive 'like raindrops'. Within
                days the men who will command Wei for thirty years have all appeared.")
      (on-map? #t))

    (event the-forged-decree
      (sequence 2)
      (actors cao-cao yuan-shao)
      (summary "A forged imperial command and a manifesto go out. Seventeen lords answer
                with contingents varying in size, each complete with its own officers,
                and converge on Luoyang. Their camps run three hundred li.")
      (historicity historical-in-outline)
      (source-note "The coalition of 190 was real and achieved almost nothing. The
                    forged decree is the novel's device for making Cao Cao its author.")
      (on-map? #t))

    (event gongsun-zan-at-pingyuan
      (sequence 3) (at pingyuan)
      (actors gongsun-zan liu-bei guan-yu zhang-fei)
      (summary "Marching west, Gongsun Zan sees a yellow flag among the mulberry trees
                and finds his old schoolfellow serving as a county magistrate with two
                sworn brothers ranked as archers. 'Thus are able men buried.'")
      (on-map? #t))

    (event the-oath-chief
      (sequence 4)
      (actors yuan-shao cao-cao yuan-shu)
      (summary "A three-storeyed altar is raised with the five banners of the quarters.
                Cao Cao proposes Yuan Shao on the strength of four generations of office;
                Yuan Shao declines twice and accepts. Blood is smeared on every lip.
                Yuan Shu is given the commissariat.")
      (on-map? #t))

    (event bao-zhong
      (sequence 5) (at sishui-pass)
      (actors hua-xiong)
      (summary "Bao Xin, jealous that the van-leader will take the honours, sends his
                brother ahead by a byroad. Hua Xiong kills him at the first pass of
                arms and sends the head to Luoyang.")
      (on-map? #f))

    (event sun-jian-starved
      (sequence 6) (at sishui-pass liangdong)
      (actors sun-jian yuan-shu hua-xiong zu-mao)
      (summary "Sun Jian breaks Hu Zhen but is driven off the pass by stones and camps
                at Liangdong. Yuan Shu withholds his grain; the camp goes hungry and
                indiscipline shows; spies carry it back. At midnight the pass attacks
                front and rear and fires the camp. Sun Jian's bowstring snaps, he throws
                the bow away, and escapes only because Zu Mao takes the purple turban
                and dies wearing it.")
      (on-map? #t))

    (event wine-still-warm
      (sequence 7) (at sishui-pass)
      (actors guan-yu hua-xiong cao-cao yuan-shao yuan-shu liu-bei)
      (summary "Hua Xiong comes down flaunting Sun Jian's captured turban on a bamboo
                pole. Yu She falls in three bouts, Pan Feng straight after. Yuan Shao
                wishes for Yan Liang and Wen Chou. Guan Yu offers his head as forfeit;
                Yuan Shu wants him beaten out of the tent for presumption; Cao Cao heats
                wine and offers it. Guan Yu says pour it out, he will be back shortly —
                and returns with the head before it cools.")
      (historicity invented)
      (source-note "Hua Xiong existed and was killed in this campaign — by Sun Jian's
                    troops. The novel takes the kill and gives it to Guan Yu, which is
                    the single most famous thing in the book that did not happen.")
      (on-map? #t))

    (event dong-zhuo-moves-up
      (sequence 8) (at luoyang hulao-pass)
      (actors dong-zhuo li-jue guo-si lv-bu yuan-wei)
      (summary "Li Ru advises destroying the Yuan family in the capital. Yuan Wei's
                household is exterminated and his head hung at the gate. Twenty legions
                go out: five to hold Sishui, fifteen with Dong Zhuo to Hulao, where Lü
                Bu is stockaded outside the pass with three.")
      (on-map? #t))

    (event lv-bu-at-hulao
      (sequence 9) (at hulao-pass)
      (actors lv-bu gongsun-zan zhang-fei guan-yu liu-bei)
      (summary "Lü Bu kills Fang Yue, then Mu Shun, then breaks Wu Anguo's wrist, then
                drives Gongsun Zan off and runs him down on Red Hare. Zhang Fei cuts in
                and holds him fifty bouts; Guan Yu joins and they make no headway in
                thirty more; Liu Bei comes in third and Lü Bu feints at him to open an
                angle and rides out through it, back to the pass.")
      (historicity invented)
      (source-note "Entirely the novel's. The most famous fight in the book has no
                    history behind it at all — which the atlas note already says.")
      (on-map? #t))))
