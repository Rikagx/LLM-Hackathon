
from dotenv import load_dotenv
from chatlas import ChatOpenAI
from shiny.express import ui

_ = load_dotenv()

chat = ChatOpenAI(
  model="gpt-4o", 
  system_prompt=open("snowflake.md").read(),
)

ui.page_opts(
  fillable = True
)

chat_ui = ui.Chat(
  "chat",
  messages = ["👋 Hi, I'm **Chatlas Assistant**! I'm here to answer questions about SPCS and Native Apps, or to generate code for you."]
)

chat_ui.ui()

@chat_ui.on_user_submit
async def _():
    response = chat.stream(chat_ui.user_input())
    await chat_ui.append_message_stream(response)
