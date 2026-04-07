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
    "naruto_classic": {
        "title": "🍥 Наруто (Оригинал)",
        "arcs": [
            {"id": "n1", "name": "Введение", "eps": "1–5"},
            {"id": "n2", "name": "Страна Волн", "eps": "6–19"},
            {"id": "n3", "name": "Экзамен на чунина", "eps": "20–67"},
            {"id": "n4", "name": "Вторжение в Коноху", "eps": "68–80"},
            {"id": "n5", "name": "Возвращение Итачи", "eps": "81–85"},
            {"id": "n6", "name": "Поиск Цунаде", "eps": "86–100"},
            {"id": "n7", "name": "Преследование Саске", "eps": "107–135"},
        ],
    },
    "naruto_shippuden": {
        "title": "🔥 Наруто Шиппуден",
        "arcs": [
            {"id": "s1", "name": "Спасение Казекаге", "eps": "1–32"},
            {"id": "s2", "name": "Долгожданная встреча", "eps": "33–56"},
            {"id": "s3", "name": "Хидан и Какузу", "eps": "72–90"},
            {"id": "s4", "name": "Предсказание учителя", "eps": "113–143"},
            {"id": "s5", "name": "Два спасителя", "eps": "152–175"},
            {"id": "s6", "name": "Совет Пяти Каге", "eps": "197–222"},
            {"id": "s7", "name": "Приручение Девятихвостого", "eps": "243–260"},
            {"id": "s8", "name": "Четвёртая Мировая Война (1 ч.)", "eps": "261–278, 282–283"},
            {"id": "s9", "name": "Четвёртая Мировая Война (2 ч.)", "eps": "296–302, 321–348"},
            {"id": "s10", "name": "Ниндзя во тьме", "eps": "349–361"},
            {"id": "s11", "name": "Четвёртая Мировая Война (3 ч.)", "eps": "362–388, 391–393"},
            {"id": "s12", "name": "Четвёртая Мировая Война (4 ч.)", "eps": "414–426"},
            {"id": "s13", "name": "Хроники Джирайи", "eps": "432–450"},
            {"id": "s14", "name": "История Итачи", "eps": "451–458"},
            {"id": "s15", "name": "Четвёртая Мировая Война (5 ч.)", "eps": "459–479"},
            {"id": "s16", "name": "Детство", "eps": "480–483"},
            {"id": "s17", "name": "История Саске", "eps": "484–488"},
            {"id": "s18", "name": "История Шикамару", "eps": "489–493"},
            {"id": "s19", "name": "Свадьба Наруто", "eps": "494–500"},
        ],
    },
}

ARC_LINKS = {
    "n1": "https://t.me/c/3799653492/11",
    "n2": "https://t.me/c/3799653492/26",
    "n3": "https://t.me/c/3799653492/74",
    "n4": "https://t.me/c/3799653492/88",
    "n5": "https://t.me/c/3799653492/94",
    "n6": "https://t.me/c/3799653492/108",
    "n7": "https://t.me/c/3799653492/138",

    "s1": "https://t.me/c/3799653492/172",
    "s2": "https://t.me/c/3799653492/198",
    "s3": "https://t.me/c/3799653492/218",
    "s4": "https://t.me/c/3799653492/250",
    "s5": "https://t.me/c/3799653492/288",
    "s6": "https://t.me/c/3799653492/314",
    "s7": "https://t.me/c/3799653492/333",
    "s8": "https://t.me/c/3799653492/354",
    "s9": "https://t.me/c/3799653492/390",
    "s10": "https://t.me/c/3799653492/404",
    "s11": "https://t.me/c/3799653492/437",
    "s12": "https://t.me/c/3799653492/451",
    "s13": "https://t.me/c/3799653492/471",
    "s14": "https://t.me/c/3799653492/480",
    "s15": "https://t.me/c/3799653492/502",
    "s16": "https://t.me/c/3799653492/507",
    "s17": "https://t.me/c/3799653492/513",
    "s18": "https://t.me/c/3799653492/519",
    "s19": "https://t.me/c/3799653492/527",
}


def main_menu_keyboard():
    return InlineKeyboardMarkup(
        [
            [InlineKeyboardButton("🍥 Наруто", callback_data="saga:naruto_classic")],
            [InlineKeyboardButton("🔥 Шиппуден", callback_data="saga:naruto_shippuden")],
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
    text = "🍥 НАРУТО — НАВИГАЦИЯ\nВыберите раздел:"
    if update.message:
        await update.message.reply_text(text, reply_markup=main_menu_keyboard())
    else:
        q = update.callback_query
        await q.edit_message_text(text, reply_markup=main_menu_keyboard())


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


def run():
    app = Application.builder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", menu))
    app.add_handler(CommandHandler("naruto", menu))
    app.add_handler(CallbackQueryHandler(on_button))
    app.run_polling()


if __name__ == "__main__":
    run()
