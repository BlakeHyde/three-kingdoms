"""Pinyin -> Wade-Giles and Yale (Mandarin) transcription.

Deliberately a lookup table rather than a rule engine. Rule-based conversion gets the
easy 90% right and then quietly mangles exactly the syllables these names are full of
(zhi/chi/shi/ri, zi/ci/si, -ian, -uo, -ong, ye/you/yu). A table cannot be subtly wrong:
either a syllable is present and correct, or ``convert`` raises. New syllables surface
as a hard build failure with the offending hanzi named, which is the point.

Tone marks are dropped -- none of the six target conventions writes tones for names --
but the umlaut is not, because lu/lü is a real distinction (盧 Lu vs 呂 Lü).
"""

from __future__ import annotations

import unicodedata

# Combining tone diacritics: macron, acute, caron, grave. Notably NOT U+0308 diaeresis.
TONE_MARKS = {"̄", "́", "̌", "̀"}


def detone(syllable: str) -> str:
    """Strip tone marks, preserve the umlaut in lü/nü."""
    decomposed = unicodedata.normalize("NFD", syllable.lower())
    kept = "".join(c for c in decomposed if c not in TONE_MARKS)
    return unicodedata.normalize("NFC", kept)


# pinyin -> (wade-giles, yale)
SYLLABLES: dict[str, tuple[str, str]] = {
    "ai": ("ai", "ai"),
    "an": ("an", "an"),
    "ba": ("pa", "ba"),
    "bai": ("pai", "bai"),
    "ban": ("pan", "ban"),
    "bao": ("pao", "bau"),
    "bei": ("pei", "bei"),
    "bi": ("pi", "bi"),
    "biao": ("piao", "byau"),
    "bing": ("ping", "bing"),
    "bo": ("po", "bwo"),
    "bu": ("pu", "bu"),
    "cang": ("ts'ang", "tsang"),
    "cao": ("ts'ao", "tsau"),
    "ce": ("ts'ê", "tse"),
    "chai": ("ch'ai", "chai"),
    "chan": ("ch'an", "chan"),
    "chang": ("ch'ang", "chang"),
    "chao": ("ch'ao", "chau"),
    "chen": ("ch'ên", "chen"),
    "cheng": ("ch'êng", "cheng"),
    "chi": ("ch'ih", "chr"),
    "chou": ("ch'ou", "chou"),
    "chu": ("ch'u", "chu"),
    "chun": ("ch'un", "chwun"),
    "ci": ("tz'ŭ", "tsz"),
    "dan": ("tan", "dan"),
    "de": ("tê", "de"),
    "deng": ("têng", "deng"),
    "di": ("ti", "di"),
    "dian": ("tien", "dyan"),
    "diao": ("tiao", "dyau"),
    "ding": ("ting", "ding"),
    "dong": ("tung", "dung"),
    "du": ("tu", "du"),
    "dun": ("tun", "dwun"),
    "fa": ("fa", "fa"),
    "fan": ("fan", "fan"),
    "fei": ("fei", "fei"),
    "fu": ("fu", "fu"),
    "gai": ("kai", "gai"),
    "gan": ("kan", "gan"),
    "ge": ("ko", "ge"),
    "gong": ("kung", "gung"),
    "guan": ("kuan", "gwan"),
    "guang": ("kuang", "gwang"),
    "gui": ("kuei", "gwei"),
    "guo": ("kuo", "gwo"),
    "hai": ("hai", "hai"),
    "han": ("han", "han"),
    "he": ("ho", "he"),
    "hou": ("hou", "hou"),
    "hu": ("hu", "hu"),
    "hua": ("hua", "hwa"),
    "huang": ("huang", "hwang"),
    "hui": ("hui", "hwei"),
    "ji": ("chi", "ji"),
    "jia": ("chia", "jya"),
    "jian": ("chien", "jyan"),
    "jiang": ("chiang", "jyang"),
    "jiao": ("chiao", "jyau"),
    "jie": ("chieh", "jye"),
    "jin": ("chin", "jin"),
    "jing": ("ching", "jing"),
    "jue": ("chüeh", "jywe"),
    "jun": ("chün", "jyun"),
    "kang": ("k'ang", "kang"),
    "kong": ("k'ung", "kung"),
    "kou": ("k'ou", "kou"),
    "kuai": ("k'uai", "kwai"),
    "lao": ("lao", "lau"),
    "li": ("li", "li"),
    "liang": ("liang", "lyang"),
    "liao": ("liao", "lyau"),
    "ling": ("ling", "ling"),
    "liu": ("liu", "lyou"),
    "lu": ("lu", "lu"),
    "lü": ("lü", "lyu"),
    "luo": ("lo", "lwo"),
    "ma": ("ma", "ma"),
    "man": ("man", "man"),
    "mai": ("mai", "mai"),
    "mei": ("mei", "mei"),
    "meng": ("mêng", "meng"),
    "mian": ("mien", "myan"),
    "mo": ("mo", "mwo"),
    "nan": ("nan", "nan"),
    "nei": ("nei", "nei"),
    "ning": ("ning", "ning"),
    "pang": ("p'ang", "pang"),
    "pei": ("p'ei", "pei"),
    "peng": ("p'êng", "peng"),
    "pi": ("p'i", "pi"),
    "ping": ("p'ing", "ping"),
    "pu": ("p'u", "pu"),
    "qi": ("ch'i", "chi"),
    "qian": ("ch'ien", "chyan"),
    "qiao": ("ch'iao", "chyau"),
    "qing": ("ch'ing", "ching"),
    "qiu": ("ch'iu", "chyou"),
    "quan": ("ch'üan", "chywan"),
    "rong": ("jung", "rung"),
    "ru": ("ju", "ru"),
    "rui": ("jui", "rwei"),
    "sang": ("sang", "sang"),
    "sha": ("sha", "sha"),
    "shan": ("shan", "shan"),
    "shang": ("shang", "shang"),
    "shao": ("shao", "shau"),
    "she": ("shê", "she"),
    "shi": ("shih", "shr"),
    "shou": ("shou", "shou"),
    "shu": ("shu", "shu"),
    "shui": ("shui", "shwei"),
    "si": ("ssŭ", "sz"),
    "song": ("sung", "sung"),
    "su": ("su", "su"),
    "suan": ("suan", "swan"),
    "sun": ("sun", "swun"),
    "tai": ("t'ai", "tai"),
    "tan": ("t'an", "tan"),
    "tao": ("t'ao", "tau"),
    "teng": ("t'êng", "teng"),
    "ting": ("t'ing", "ting"),
    "tong": ("t'ung", "tung"),
    "wan": ("wan", "wan"),
    "wang": ("wang", "wang"),
    "wei": ("wei", "wei"),
    "wen": ("wên", "wen"),
    "wu": ("wu", "wu"),
    "xi": ("hsi", "syi"),
    "xia": ("hsia", "sya"),
    "xian": ("hsien", "syan"),
    "xiang": ("hsiang", "syang"),
    "xiao": ("hsiao", "syau"),
    "xie": ("hsieh", "sye"),
    "xin": ("hsin", "syin"),
    "xiong": ("hsiung", "syung"),
    "xiu": ("hsiu", "syou"),
    "xu": ("hsü", "syu"),
    "xun": ("hsün", "syun"),
    "yan": ("yen", "yan"),
    "yang": ("yang", "yang"),
    "ye": ("yeh", "ye"),
    "yi": ("i", "yi"),
    "yong": ("yung", "yung"),
    "you": ("yu", "you"),
    "yu": ("yü", "yu"),
    "yuan": ("yüan", "ywan"),
    "yue": ("yüeh", "ywe"),
    "yun": ("yün", "yun"),
    "zan": ("tsan", "dzan"),
    "zao": ("tsao", "dzau"),
    "zhang": ("chang", "jang"),
    "zhao": ("chao", "jau"),
    "zheng": ("chêng", "jeng"),
    "zhi": ("chih", "jr"),
    "zhong": ("chung", "jung"),
    "zhou": ("chou", "jou"),
    "zhu": ("chu", "ju"),
    "zhuo": ("cho", "jwo"),
    "cai": ("ts'ai", "tsai"),
    "che": ("ch'ê", "che"),
    "cong": ("ts'ung", "tsung"),
    "da": ("ta", "da"),
    "ding": ("ting", "ding"),
    "fang": ("fang", "fang"),
    "feng": ("fêng", "feng"),
    "gu": ("ku", "gu"),
    "hao": ("hao", "hau"),
    "heng": ("hêng", "heng"),
    "huo": ("huo", "hwo"),
    "ke": ("k'o", "ke"),
    "lei": ("lei", "lei"),
    "lin": ("lin", "lin"),
    "long": ("lung", "lung"),
    "mao": ("mao", "mau"),
    "mi": ("mi", "mi"),
    "mu": ("mu", "mu"),
    "ren": ("jên", "ren"),
    "shen": ("shên", "shen"),
    "sheng": ("shêng", "sheng"),
    "sui": ("sui", "swei"),
    "ta": ("t'a", "ta"),
    "tian": ("t'ien", "tyan"),
    "tuo": ("t'o", "two"),
    "yin": ("yin", "yin"),
    "zhan": ("chan", "jan"),
    "zhen": ("chên", "jen"),
    "zu": ("tsu", "dzu"),
    "zuo": ("tso", "dzwo"),
    "shuang": ("shuang", "shwang"),
    "dang": ("tang", "dang"),
    "men": ("mên", "men"),
    "dai": ("tai", "dai"),
    "xing": ("hsing", "sying"),
    "lang": ("lang", "lang"),
    "bao": ("pao", "bau"),
}


class UnknownSyllable(KeyError):
    """Raised rather than guessing, so a missing syllable fails the build loudly."""


def convert(pinyin: str, system: str) -> str:
    """Transcribe one toned pinyin syllable into 'wadegiles' or 'yale'."""
    bare = detone(pinyin)
    try:
        wg, yale = SYLLABLES[bare]
    except KeyError:
        raise UnknownSyllable(
            f"pinyin syllable {bare!r} (from {pinyin!r}) is not in the transcription "
            f"table; add it to tools/romanize.py SYLLABLES"
        ) from None
    return {"wadegiles": wg, "yale": yale}[system]


def capitalize(word: str) -> str:
    """Title-case a transcribed word without disturbing what follows the first letter.

    ``str.capitalize`` would lowercase the rest, which destroys Wade-Giles apostrophes'
    neighbours in hyphenated given names and the ü in Lü.
    """
    return word[:1].upper() + word[1:] if word else word
