;;; chapter-3.scm — 三國演義 第三回
;;;
;;; Structural reading of chapter 3. See chapter-1.scm for conventions.
;;;
;;; The hinge of the opening arc. Almost everything happens in or just outside Luoyang
;;; within a few days: He Jin walks into the palace and is killed, the palace burns, the
;;; Emperor is chased into the countryside and recovered by the man who will keep him,
;;; and the chapter ends with Lü Bu killing the father who raised him for a horse.

(chapter 3

  (title
    (chinese "議溫明董卓叱丁原　餽金珠李肅說呂布")
    (brewitt "Tung Cho Silences Ting Yüan; Li Su Bribes Lü Pu")
    (atlas   "Dong Zhuo Rebukes the Emperor at Wenming Garden; Li Su Tempts Lü Bu with Red Hare"))

  (year 189)

  ;; ------------------------------------------------------------------ places

  (places

    (place luoyang
      (hanzi "洛陽")
      (atlas-id luoyang) (on-map? #t)
      (role "The capital, and effectively the whole setting."))

    (place mianchi
      (hanzi "澠池")
      (atlas-id #f) (on-map? #f)
      (role "Where Dong Zhuo halts his army on the way in, close enough to threaten and
             far enough to disclaim.")
      (gap "Not in the gazetteer. It marks the moment the western army is within reach
            of the capital, which is the chapter's whole pivot."))

    (place beimang
      (hanzi "北邙")
      (atlas-id #f) (on-map? #f)
      (role "The hills north of Luoyang. The eunuchs drag the two boys here in the dark;
             Zhang Rang drowns himself in the river below; the children hide in the
             grass and are led out by fireflies.")
      (gap "The most vivid scene in the chapter and the atlas has no point for it."))

    (place wenming-garden
      (hanzi "溫明園")
      (atlas-id #f) (on-map? #f)
      (role "Where Dong Zhuo assembles the officials and first proposes deposing the
             Emperor. Ding Yuan stands up to him here."))

    (place jingzhou
      (hanzi "荊州")
      (atlas-id xiangyang) (on-map? #f)
      (role "Ding Yuan's province.")
      (editions
        (note "Both Chinese editions make Ding Yuan 荊州刺史, Inspector of Jing province,
               and Brewitt-Taylor follows them. History has him Inspector of Bing (并州),
               which is also where his army and Lü Bu come from. The novel's geography
               here is simply wrong, and consistently so."))))

  ;; -------------------------------------------------------------- characters

  (characters

    (character he-jin
      (hanzi "何進") (courtesy "遂高")
      (atlas-id hejin) (on-map? #t) (at luoyang)
      (role "Walks into the palace against every warning, is met at the Gate of
             Abundant Virtue, is reviled by Zhang Rang for his ingratitude, and is cut
             down. His head is thrown back over the wall."))

    (character zhang-rang
      (hanzi "張讓")
      (atlas-id #f) (on-map? #f) (at luoyang beimang)
      (role "Chief of the Ten. Kills He Jin, fires the palace, carries off the Emperor,
             and drowns himself in the river at Beimang."))

    (character duan-gui
      (hanzi "段珪")
      (atlas-id #f) (on-map? #f) (at beimang)
      (role "The other abductor. Run down and killed by Min Gong, who carries the head
             at his saddle."))

    (character yuan-shao
      (hanzi "袁紹") (courtesy "本初")
      (atlas-id yuanshao) (on-map? #t) (at luoyang)
      (role "Waits outside the gate, is answered with He Jin's head, and turns the
             palace into a massacre — 'sparing none', so that many beardless men are
             killed by mistake. Later draws on Dong Zhuo in open court and walks out."))

    (character yuan-shu
      (hanzi "袁術") (courtesy "公路")
      (atlas-id yuanshu) (on-map? #f) (at luoyang)
      (role "Burns the gate and leads the killing inside.")
      (gap "The atlas does not pin him this chapter."))

    (character cao-cao
      (hanzi "曹操") (courtesy "孟德")
      (atlas-id caocao) (on-map? #t) (at luoyang)
      (role "Says the eunuchs should have been dealt with by one gaoler, not an army;
             then puts out the fires, and is the one who thinks to send men after the
             Emperor."))

    (character lu-zhi
      (hanzi "盧植") (courtesy "子幹")
      (atlas-id luzhi) (on-map? #f) (at luoyang)
      (role "Retired, hears the palace is in revolt, puts on armour and stops Duan Gui
             carrying off the Empress. Later tells Dong Zhuo to his face that he is
             neither I Yin nor Huo Guang and has no standing to depose anyone.")
      (gap "Not pinned in the atlas for this chapter, though he twice intervenes."))

    (character min-gong
      (hanzi "閔貢")
      (atlas-id #f) (on-map? #f) (at beimang)
      (role "Rides down Duan Gui, then finds the two boys at the farm and puts the
             Emperor on the only decent horse."))

    (character cui-yi
      (hanzi "崔毅")
      (atlas-id #f) (on-map? #f) (at beimang)
      (role "The farmer who dreams of two red suns falling behind his house, finds the
             boys in the straw, and serves them on his knees."))

    (character liu-bian
      (hanzi "劉辯")
      (atlas-id #f) (on-map? #f) (at luoyang beimang)
      (role "The young Emperor. Too frightened to answer when challenged on the road."))

    (character liu-xie
      (hanzi "劉協")
      (atlas-id emperorxian) (on-map? #t) (at luoyang beimang)
      (role "The Prince of Chenliu, nine years old. It is he who says they must find a
             way out of the thicket, he who names himself to the farmer, and he who
             asks Dong Zhuo on the road whether he has come to protect the chariot or
             steal it — and orders him to dismount. Dong Zhuo obeys, and decides on the
             spot to put this boy on the throne.")
      (note "The chapter's best joke: Dong Zhuo resolves to depose an emperor because
             the wrong child impressed him."))

    (character dong-zhuo
      (hanzi "董卓") (courtesy "仲穎")
      (atlas-id dongzhuo) (on-map? #t) (at mianchi luoyang)
      (role "Marches on the capital, meets the fleeing court on the road, occupies the
             city, and starts talking about deposing the Emperor within days."))

    (character li-ru
      (hanzi "李儒")
      (atlas-id #f) (on-map? #f) (at luoyang)
      (role "Dong Zhuo's son-in-law and adviser, and the voice behind every move he
             makes. Writes the memorial, stops the killing of Ding Yuan at the banquet
             because he has seen the man standing behind him, and identifies Lü Bu.")
      (gap "One of the most consequential figures in the opening twenty chapters and
            the atlas roster does not contain him at all."))

    (character niu-fu
      (hanzi "牛輔") (atlas-id #f) (on-map? #f)
      (role "Dong Zhuo's other son-in-law, left holding the west."))

    (character ding-yuan
      (hanzi "丁原") (courtesy "建陽")
      (atlas-id #f) (on-map? #f) (at luoyang)
      (role "Stands up at the banquet and calls Dong Zhuo a rebel to his face; survives
             only because Li Ru sees Lü Bu behind him. Beats Dong Zhuo in the field the
             next day. Killed in his tent two nights later by his own adopted son, over
             a horse.")
      (gap "Not in the atlas roster. He is the reason Lü Bu matters."))

    (character lv-bu
      (hanzi "呂布") (courtesy "奉先")
      (atlas-id lvbu) (on-map? #t) (at luoyang)
      (role "Introduced riding up and down outside the gate on a fiery horse, and Li Ru
             tells Dong Zhuo to stay out of his way. Wins the field the next day
             single-handed. Then kills Ding Yuan — 'do you think I am willing to be a
             son of yours?' — and asks Dong Zhuo to let him bow to him as father."))

    (character li-su
      (hanzi "李肅")
      (atlas-id #f) (on-map? #f) (at luoyang)
      (role "A minor officer and Lü Bu's fellow villager, who volunteers to buy him
             with Red Hare, a thousand taels of gold, ten strings of pearls and a
             jewelled belt — and does it in one evening's conversation.")
      (gap "Not in the roster, though the whole transaction is his."))

    (character red-hare
      (hanzi "赤兔")
      (kind horse)
      (atlas-id #f) (on-map? #f)
      (role "Ten feet head to tail, eight to the neck, the colour of glowing charcoal.
             Li Ru's verdict on giving it away: 'one cannot grudge a horse to win an
             empire.'"))

    (character wang-yun
      (hanzi "王允") (courtesy "子師")
      (atlas-id wangyun) (on-map? #t) (at luoyang)
      (role "Defuses the banquet by proposing the question be put off — the first of
             several times he survives by saying the reasonable thing at the right
             moment."))

    (character bao-xin
      (hanzi "鮑信")
      (atlas-id #f) (on-map? #f) (at luoyang)
      (role "Tells Yuan Shao that Dong Zhuo should be removed now. Told to wait, he
             leaves the capital for Taishan instead."))

    (character wu-kuang
      (hanzi "吳匡")
      (atlas-id #f) (on-map? #f) (at luoyang)
      (role "Kills He Miao in the palace on the grounds that he was in the plot against
             his own brother.")))

  ;; ------------------------------------------------------------------ events

  (events

    (event dong-zhuo-summoned
      (sequence 1) (at mianchi)
      (actors dong-zhuo li-ru he-jin lu-zhi)
      (summary "Dong Zhuo receives the summons and comes east delighted, sending ahead
                a memorial demanding the eunuchs' removal. Zheng Tai calls him a wild
                beast whose prey will be men; Lu Zhi says he is a wolf in an innocent
                skin. Both resign when He Jin will not listen, as do more than half the
                ministers.")
      (on-map? partial))

    (event murder-of-he-jin
      (sequence 2) (at luoyang)
      (actors he-jin zhang-rang yuan-shao cao-cao)
      (summary "The eunuchs hide assassins at the Gate of Abundant Virtue and have the
                Empress summon He Jin. His escort is stopped at the gate; he goes in
                alone and proudly. Zhang Rang reviles him for the ingratitude of a
                huckstering family raised by eunuchs, and he is cut down.")
      (on-map? #t))

    (event palace-massacre
      (sequence 3) (at luoyang)
      (actors yuan-shao yuan-shu cao-cao lu-zhi wu-kuang)
      (summary "The gate is fired, Yuan Shu bursts in, and the killing goes by
                appearance rather than office: many beardless men die by mistake. The
                palace burns. Lu Zhi stops Duan Gui carrying off the Empress, who gets
                out through a window.")
      (on-map? #t))

    (event flight-to-beimang
      (sequence 4) (at beimang)
      (actors zhang-rang duan-gui liu-bian liu-xie cui-yi min-gong)
      (summary "The eunuchs run the two boys out through the smoke to the Beimang hills
                at the third watch. Zhang Rang drowns himself. The children hide in the
                grass till the fourth watch, cold and hungry, then knot their clothes
                together to climb the bank — and are led to the road by a swarm of
                fireflies. A farmer who has dreamt of two red suns takes them in.")
      (on-map? #f)
      (gap "Beimang is not in the gazetteer."))

    (event meeting-on-the-road
      (sequence 5) (at luoyang)
      (actors dong-zhuo liu-xie liu-bian yuan-shao)
      (summary "The returning cavalcade meets Dong Zhuo's army. The Emperor is too
                frightened to speak; the Prince of Chenliu rides forward and asks
                whether he has come to protect the chariot or to steal it, and tells him
                to dismount. He does. From this, Dong Zhuo forms the intention of
                deposing one boy for the other.")
      (on-map? #t))

    (event seal-missing
      (sequence 6) (at luoyang)
      (summary "Order is restored in the palace, and the Hereditary Seal cannot be
                found.")
      (on-map? #f)
      (note "Set up here and paid off in chapter 6, when Sun Jian finds it in a well."))

    (event wenming-banquet
      (sequence 7) (at wenming-garden)
      (actors dong-zhuo ding-yuan lu-zhi wang-yun li-ru lv-bu)
      (summary "Dong Zhuo proposes the deposition over wine. Ding Yuan strikes the table
                and calls him a rebel; Dong Zhuo draws, and Li Ru stops him because he
                has noticed the man behind Ding Yuan handling a spear. Lu Zhi argues the
                precedents and nearly dies for it. Wang Yun gets the party adjourned.")
      (on-map? partial))

    (event ding-yuan-in-the-field
      (sequence 8)
      (actors ding-yuan lv-bu dong-zhuo)
      (summary "Ding Yuan comes out to fight the next day. Lü Bu rides straight at Dong
                Zhuo, who flees; the beaten army makes camp elsewhere. Dong Zhuo: 'If he
                were only on my side I would defy the whole world.'")
      (on-map? #f))

    (event buying-lv-bu
      (sequence 9)
      (actors li-su lv-bu dong-zhuo li-ru red-hare)
      (summary "Li Su takes Red Hare, gold, pearls and a jewelled belt to his fellow
                villager and works round to it by degrees: the clever bird chooses its
                branch. Lü Bu himself proposes the murder. That night he walks into
                Ding Yuan's tent where the man is reading by a single candle, is greeted
                as 'my son', and takes his head off.")
      (historicity historical-in-outline)
      (source-note "Lü Bu did kill Ding Yuan and go over to Dong Zhuo. Red Hare was real.
                    That the horse was the price is the novel's.")
      (on-map? #t))

    (event yuan-shao-draws
      (sequence 10) (at luoyang)
      (actors dong-zhuo yuan-shao)
      (summary "At a second banquet, with Lü Bu's armed men posted, Dong Zhuo announces
                the deposition as done. Only Yuan Shao objects: 'If your sword is sharp,
                mine is never blunt.' The two stand facing each other and the chapter
                ends there.")
      (on-map? #t))))
