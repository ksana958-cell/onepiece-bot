import os
import json
from pathlib import Path
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, ContextTypes

TOKEN = os.getenv("BOT_TOKEN")
if not TOKEN:
    raise RuntimeError("BOT_TOKEN is not set")

STATE_FILE = Path("state.json")


def load_state():
    if STATE_FILE.exists():
        try:
            return json.loads(STATE_FILE.read_text(encoding="utf-8"))
        except Exception:
            return {}
    return {}


def save_state(state: dict):
    STATE_FILE.write_text(json.dumps(state, ensure_ascii=False, indent=2), encoding="utf-8")


STATE = load_state()

DATA = {
    "east": {
        "title": "🌊 Ист Блю",
        "arcs": [
            {"id": "a1", "name": "На заре приключений", "eps": "1–3"},
            {"id": "a2", "name": "Оранж-Таун", "eps": "4–8"},
            {"id": "a3", "name": "Деревня Усоппа", "eps": "9–18"},
            {"id": "a4", "name": "Ресторан «Барати»", "eps": "19–30"},
            {"id": "a5", "name": "Арлонг-Парк", "eps": "31–45"},
            {"id": "a6", "name": "История Багги", "eps": "46–47"},
            {"id": "a7", "name": "Логтаун", "eps": "48–53"},
            {"id": "a8", "name": "Апис (филлер)", "eps": "54–61"},
        ],
    },
    "alabasta": {
        "title": "🏜 Алабаста-сага",
        "arcs": [
            {"id": "a9", "name": "Реверс-Маунтин", "eps": "62–63"},
            {"id": "a10", "name": "Виски-Пик", "eps": "64–67"},
            {"id": "a11", "name": "История Коби и Хельмеппо", "eps": "68–69"},
            {"id": "a12", "name": "Литл-Гарден", "eps": "70–77"},
            {"id": "a13", "name": "Остров Драм", "eps": "78–91"},
            {"id": "a14", "name": "Алабаста", "eps": "92–130"},
            {"id": "a15", "name": "После Алабасты", "eps": "131–135"},
        ],
    },
    "skypiea": {
        "title": "☁️ Скайпия-сага",
        "arcs": [
            {"id": "a16", "name": "Козий остров (филлер)", "eps": "136–138"},
            {"id": "a17", "name": "Остров Рулука (филлер)", "eps": "139–143"},
            {"id": "a18", "name": "Джая", "eps": "144–152"},
            {"id": "a19", "name": "Скайпия", "eps": "153–195"},
            {"id": "a20", "name": "G-8 (филлер)", "eps": "196–206"},
        ],
    },
    "water7": {
        "title": "🚆 Water 7-сага",
        "arcs": [
            {"id": "a21", "name": "Длинно-круглая земля", "eps": "207–219"},
            {"id": "a22", "name": "Океанский сон (филлер)", "eps": "220–224"},
            {"id": "a23", "name": "Возвращение Фокси (филлер)", "eps": "225–228"},
            {"id": "a24", "name": "Water 7", "eps": "227–263"},
            {"id": "a25", "name": "Эниес-Лобби", "eps": "264–312"},
            {"id": "a26", "name": "После Эниес-Лобби", "eps": "313–325"},
        ],
    },
    "thriller": {
        "title": "🎃 Триллер Барк-сага",
        "arcs": [
            {"id": "a27", "name": "Ледяной охотник (филлер)", "eps": "326–336"},
            {"id": "a28", "name": "Триллер-Барк", "eps": "337–381"},
            {"id": "a29", "name": "Остров-спа (филлер)", "eps": "382–384"},
        ],
    },
    "war": {
        "title": "⚔️ Сага Войны",
        "arcs": [
            {"id": "a30", "name": "Архипелаг Сабаоди", "eps": "385–407"},
            {"id": "a31", "name": "Амазон Лили", "eps": "408–422"},
            {"id": "a32", "name": "Импел-Даун, часть 1", "eps": "422–425"},
            {"id": "a33", "name": "Литл Ист Блю (филлер)", "eps": "426–429"},
            {"id": "a34", "name": "Импел-Даун, часть 2", "eps": "430–456"},
            {"id": "a35", "name": "Маринфорд", "eps": "457–489"},
            {"id": "a36", "name": "После Войны", "eps": "490–516"},
        ],
    },
    "newworld": {
        "title": "🌍 Новый Свет",
        "arcs": [
            {"id": "a37", "name": "Возвращение на Сабаоди", "eps": "517–526"},
            {"id": "a38", "name": "Остров Рыболюдей", "eps": "527–574"},
            {"id": "a39", "name": "Амбиции Z (филлер)", "eps": "575–578"},
            {"id": "a40", "name": "Панк Хазард", "eps": "579–625"},
            {"id": "a41", "name": "Возвращение Цезаря (филлер)", "eps": "626–628"},
            {"id": "a42", "name": "Дресс Роза", "eps": "629–746"},
            {"id": "a43", "name": "Серебряный рудник (филлер)", "eps": "747–750"},
            {"id": "a44", "name": "Зоу", "eps": "751–779"},
            {"id": "a45", "name": "Дозорные-сверхновые", "eps": "780–782"},
            {"id": "a46", "name": "Пирожный остров", "eps": "783–877"},
            {"id": "a47", "name": "Совет Королей (Ревери)", "eps": "878–889"},
            {"id": "a48", "name": "Страна Вано", "eps": "890–1085"},
            {"id": "a49", "name": "Яичная Голова", "eps": "1086–1155"},
        ],
    },
}

ARC_LINKS = {
    "a1": "https://t.me/c/3798271874/6",
    "a2": "https://t.me/c/3798271874/12",
    "a3": "https://t.me/c/3798271874/23",
    "a4": "https://t.me/c/3798271874/36",
    "a5": "https://t.me/c/3798271874/51",
    "a6": "https://t.me/c/3798271874/54",
    "a7": "https://t.me/c/3798271874/62",
    "a8": "https://t.me/c/3798271874/72",
    "a9": "https://t.me/c/3798271874/75",
    "a10": "https://t.me/c/3798271874/80",
    "a11": "https://t.me/c/3798271874/83",
    "a12": "https://t.me/c/3798271874/92",
    "a13": "https://t.me/c/3798271874/107",
    "a14": "https://t.me/c/3798271874/147",
    "a15": "https://t.me/c/3798271874/153",
    "a16": "https://t.me/c/3798271874/157",
    "a17": "https://t.me/c/3798271874/163",
    "a18": "https://t.me/c/3798271874/173",
    "a19": "https://t.me/c/3798271874/217",
    "a20": "https://t.me/c/3798271874/229",
    "a21": "https://t.me/c/3798271874/243",
    "a22": "https://t.me/c/3798271874/249",
    "a23": "https://t.me/c/3798271874/254",
    "a24": "https://t.me/c/3798271874/290",
    "a25": "https://t.me/c/3798271874/340",
    "a26": "https://t.me/c/3798271874/354",
    "a27": "https://t.me/c/3798271874/366",
    "a28": "https://t.me/c/3798271874/412",
    "a29": "https://t.me/c/3798271874/416",
    "a30": "https://t.me/c/3798271874/440",
    "a31": "https://t.me/c/3798271874/455",
    "a32": "https://t.me/c/3798271874/460",
    "a33": "https://t.me/c/3798271874/465",
    "a34": "https://t.me/c/3798271874/493",
    "a35": "https://t.me/c/3798271874/527",
    "a36": "https://t.me/c/3798271874/555",
    "a37": "https://t.me/c/3798271874/566",
    "a38": "https://t.me/c/3798271874/615",
    "a39": "https://t.me/c/3798271874/620",
    "a40": "https://t.me/c/3798271874/668",
    "a41": "https://t.me/c/3798271874/672",
    "a42": "https://t.me/c/3798271874/791",
    "a43": "https://t.me/c/3798271874/796",
    "a44": "https://t.me/c/3798271874/826",
    "a45": "https://t.me/c/3798271874/830",
    "a46": "https://t.me/c/3798271874/926",
    "a47": "https://t.me/c/3798271874/939",
    "a48": "https://t.me/c/3798271874/1136",
    "a49": "https://t.me/c/3798271874/1207",
}


def main_menu_keyboard():
    return InlineKeyboardMarkup(
        [
            [
                InlineKeyboardButton("🌊 Ист Блю", callback_data="saga:east"),
                InlineKeyboardButton("🏜 Алабаста", callback_data="saga:alabasta"),
            ],
            [
                InlineKeyboardButton("☁️ Скайпия", callback_data="saga:skypiea"),
                InlineKeyboardButton("🚆 Water 7", callback_data="saga:water7"),
            ],
            [
                InlineKeyboardButton("🎃 Триллер Барк", callback_data="saga:thriller"),
                InlineKeyboardButton("⚔️ Война", callback_data="saga:war"),
            ],
            [InlineKeyboardButton("🌍 Новый Свет", callback_data="saga:newworld")],
        ]
    )


def saga_keyboard(saga_key: str):
    arcs = DATA[saga_key]["arcs"]
    rows = []
    for arc in arcs:
        link = ARC_LINKS.get(arc["id"])
        title = f"▫️ {arc['name']} ({arc['eps']})"
        if link:
            rows.append([InlineKeyboardButton(title, url=link)])
        else:
            rows.append([InlineKeyboardButton(f"{title} (нет ссылки)", callback_data="noop")])
    rows.append([InlineKeyboardButton("⬅️ Назад", callback_data="back:main")])
    return InlineKeyboardMarkup(rows)


async def menu(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.message:
        await update.message.reply_text("🏴‍☠️ ВАН ПИС — НАВИГАЦИЯ\nВыберите сагу:", reply_markup=main_menu_keyboard())
    else:
        q = update.callback_query
        await q.edit_message_text("🏴‍☠️ ВАН ПИС — НАВИГАЦИЯ\nВыберите сагу:", reply_markup=main_menu_keyboard())


async def on_button(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()

    data = query.data
    if data == "noop":
        return

    if data.startswith("saga:"):
        saga_key = data.split(":", 1)[1]
        title = DATA[saga_key]["title"]
        await query.edit_message_text(f"{title}\n\nВыберите арку:", reply_markup=saga_keyboard(saga_key))
        return

    if data == "back:main":
        await menu(update, context)
        return


async def set_channel(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.message:
        return

    if not update.message.reply_to_message:
        await update.message.reply_text(
            "Сделай так:\n"
            "1) Перешли мне ЛЮБОЕ сообщение из канала\n"
            "2) Ответь на него командой /set_channel"
        )
        return

    fwd = update.message.reply_to_message.forward_from_chat
    if not fwd:
        await update.message.reply_text(
            "Я не вижу канал в пересланном сообщении.\n"
            "Перешли сообщение из КАНАЛА (не из чата) и снова ответь на него /set_channel."
        )
        return

    STATE["channel_id"] = fwd.id
    save_state(STATE)
    await update.message.reply_text(f"Готово! Канал привязан.\nchannel_id: {fwd.id}")


async def post_nav(update: Update, context: ContextTypes.DEFAULT_TYPE):
    channel_id = STATE.get("channel_id")
    if not channel_id:
        await update.message.reply_text(
            "Сначала привяжи канал:\n"
            "1) Перешли мне любое сообщение из канала\n"
            "2) Ответь на него /set_channel"
        )
        return

    sent = await context.bot.send_message(
        chat_id=channel_id,
        text="🏴‍☠️ ВАН ПИС — НАВИГАЦИЯ\nВыберите сагу:",
        reply_markup=main_menu_keyboard(),
    )

    STATE["last_nav_message_id"] = sent.message_id
    save_state(STATE)

    await update.message.reply_text("Навигация отправлена в канал ✅")


async def pin_nav(update: Update, context: ContextTypes.DEFAULT_TYPE):
    channel_id = STATE.get("channel_id")
    msg_id = STATE.get("last_nav_message_id")

    if not channel_id or not msg_id:
        await update.message.reply_text("Сначала сделай /post_nav (чтобы я знал, какое сообщение закреплять).")
        return

    try:
        await context.bot.pin_chat_message(chat_id=channel_id, message_id=msg_id, disable_notification=True)
        await update.message.reply_text("Закрепил навигацию ✅")
    except Exception as e:
        await update.message.reply_text(
            "Не смог закрепить.\n"
            "Проверь, что бот админ в канале и у него есть право «Закреплять сообщения».\n"
            f"Ошибка: {e}"
        )


def run():
    app = Application.builder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", menu))
    app.add_handler(CommandHandler("onepiece", menu))
    app.add_handler(CommandHandler("set_channel", set_channel))
    app.add_handler(CommandHandler("post_nav", post_nav))
    app.add_handler(CommandHandler("pin_nav", pin_nav))
    app.add_handler(CallbackQueryHandler(on_button))
    app.run_polling()


if __name__ == "__main__":
    run()
