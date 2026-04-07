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
        "title": "🍥 Наруто",
        "arcs": [
            {"id": "n1", "name": "Введение", "eps": "1–5"},
            {"id": "n2", "name": "Страна Волн", "eps": "6–19"},
            {"id": "n3", "name": "Экзамен на звание Чунина", "eps": "20–67"},
            {"id": "n4", "name": "Вторжение в Селение Листвы", "eps": "68–80"},
            {"id": "n5", "name": "Возвращение Итачи", "eps": "81–85"},
            {"id": "n6", "name": "Цунаде", "eps": "86–100"},
            {"id": "n7", "name": "Преследование Саске", "eps": "107–135"},
        ],
    },
    "naruto_shippuden": {
        "title": "🔥 Наруто Ураганные Хроники",
        "arcs": [
            {"id": "s1", "name": "Спасение Казекаге", "eps": "1–32"},
            {"id": "s2", "name": "Долгожданная встреча", "eps": "33–56"},
            {"id": "s3", "name": "Бессмертные опустошители – Хидан и Какузу", "eps": "72–90"},
            {"id": "s4", "name": "Предсказание учителя и месть", "eps": "113–143"},
            {"id": "s5", "name": "Два спасителя", "eps": "152–175"},
            {"id": "s6", "name": "Совет Пяти Каге", "eps": "197–222"},
            {"id": "s7", "name": "Приручение Девятихвостого", "eps": "243–260"},
            {"id": "s8", "name": "Четвёртая Мировая Война (1 ч.)", "eps": "261–278, 282–283"},
            {"id": "s9", "name": "Четвёртая Мировая Война (2 ч.)", "eps": "296–302, 321–348"},
            {"id": "s10", "name": "Ниндзя, живущий во тьме", "eps": "349–361"},
            {"id": "s11", "name": "Четвёртая Мировая Война (3 ч.)", "eps": "362–388, 391–393"},
            {"id": "s12", "name": "Четвёртая Мировая Война (4 ч.)", "eps": "414–426"},
            {"id": "s13", "name": "Хроники Джирайи: сказание о храбром Наруто", "eps": "432–450"},
            {"id": "s14", "name": "Настоящая легенда Итачи: Свет и Тьма", "eps": "451–458"},
            {"id": "s15", "name": "Четвёртая Мировая Война (5 ч.)", "eps": "459–479"},
            {"id": "s16", "name": "Детство", "eps": "480–483"},
            {"id": "s17", "name": "История Саске: Рассвет", "eps": "484–488"},
            {"id": "s18", "name": "Хроники Шикамару: Облако, плывущее в тихом сумраке", "eps": "489–493"},
            {"id": "s19", "name": "Хроники Скрытого Листа: Идеальный день для свадьбы", "eps": "494–500"},
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
            [InlineKeyboardButton("🔥 Ураганные Хроники", callback_data="saga:naruto_shippuden")],
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
        if saga_key not in DATA:
            await query.edit_message_text("Раздел не найден.", reply_markup=main_menu_keyboard())
            return
        title = DATA[saga_key]["title"]
        await query.edit_message_text(f"{title}\n\nВыберите арку:", reply_markup=saga_keyboard(saga_key))
        return

    if data == "back:main":
        await menu(update, context)
        return


async def set_channel(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.message:
        return

    if update.message.reply_to_message and update.message.reply_to_message.forward_from_chat:
        fwd_chat = update.message.reply_to_message.forward_from_chat
        STATE["channel_id"] = fwd_chat.id
        save_state(STATE)
        await update.message.reply_text(f"Готово! Канал привязан.\nchannel_id: {fwd_chat.id}")
        return

    await update.message.reply_text(
        "❌ Не вижу канал.\n\n"
        "Сделай так:\n"
        "1) Перешли мне ЛЮБОЕ сообщение из канала\n"
        "2) Ответь на него командой /set_channel"
    )


async def post_nav(update: Update, context: ContextTypes.DEFAULT_TYPE):
    channel_id = STATE.get("channel_id")
    if not channel_id:
        await update.message.reply_text("Сначала привяжи канал командой /set_channel.")
        return

    sent = await context.bot.send_message(
        chat_id=channel_id,
        text="🍥 НАРУТО — НАВИГАЦИЯ\nВыберите раздел:",
        reply_markup=main_menu_keyboard(),
    )

    STATE["last_nav_message_id"] = sent.message_id
    save_state(STATE)

    await update.message.reply_text("Навигация отправлена в канал ✅")


async def pin_nav(update: Update, context: ContextTypes.DEFAULT_TYPE):
    channel_id = STATE.get("channel_id")
    msg_id = STATE.get("last_nav_message_id")

    if not channel_id or not msg_id:
        await update.message.reply_text("Сначала сделай /post_nav, чтобы было что закреплять.")
        return

    try:
        await context.bot.pin_chat_message(chat_id=channel_id, message_id=msg_id, disable_notification=True)
        await update.message.reply_text("Закрепил навигацию ✅")
    except Exception as e:
        await update.message.reply_text(
            "Не смог закрепить.\n"
            "Проверь права бота в канале: «Публиковать» и «Закреплять».\n"
            f"Ошибка: {e}"
        )


def run():
    app = Application.builder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", menu))
    app.add_handler(CommandHandler("naruto", menu))
    app.add_handler(CommandHandler("set_channel", set_channel))
    app.add_handler(CommandHandler("post_nav", post_nav))
    app.add_handler(CommandHandler("pin_nav", pin_nav))
    app.add_handler(CallbackQueryHandler(on_button))
    app.run_polling()


if __name__ == "__main__":
    run()
