import clips
import tkinter as tk

font_family = "Segoe UI"

def test(num):
    print(num)

class App(tk.Tk):

    def __init__(self):
        super().__init__()
        self.title("Man's gift guide")
        self.geometry("1280x720")
        self.resizable(False, False)

        self.question_label = tk.Label(self, text="Question", wraplength=700)
        self.question_label.config(font=(font_family, 20, "bold"))
        self.question_label.pack(pady=(90, 0))

        self.buttons_frame = tk.Frame(self)
        self.buttons_frame.pack(pady=(70, 0))

        self.back_button = tk.Button(self, text="< Back", command=self.go_back)
        self.back_button.config(font=(font_family, 10))
        self.back_button.pack(side="bottom", pady=50)

    def set_question(self, question, answers):
        self.question_label.config(text=question)

        for qb in self.buttons_frame.winfo_children():
            qb.destroy()

        for i, label in enumerate(answers[:6]):
            row = i // 2
            col = i % 2
            btn = tk.Button(self.buttons_frame, command=(lambda l = label: self.on_click(l)), text=label,
                            width=50, height=5, wraplength=200,
                            bg="#ffd966", activebackground="#ffe187", borderwidth=5, relief="ridge",
                            font=(font_family, 9))
            btn.grid(row=row, column=col, padx=5, pady=3)

    def on_click(self, answer):
        print(answer)

    def go_back(self):
        print("back")


if __name__ == "__main__":
    app = App()

    question = "Was he so excited to test out the new grill right away that almost started the house on fire?"
    answers = ["Yes that is exactly what happened.",
               "No... He actually did start the house on fire."]

    question1 = "This is gonna be hard. Guys don't buy gifts for other guys. Why are you buying him a gift?"
    answers1 = ["Dad",
               "Brother",
               "Crazy Uncle Charlie",
               "Co-worker",
               "Father-in-law"]

    question2 = "Let's face it, you are in trouble. Why are you buying her a gift? Let's face it, you are in trouble. Why are you buying her a gift?"
    answers2 = ["Wife",
               "Girlfriend",
               "Mom",
               "Mother-in-law",
               "Sister",
               "Co-worker"]

    app.set_question(question2, answers2)

    app.mainloop()
