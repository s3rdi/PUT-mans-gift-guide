import clips
import tkinter as tk
import json

font_family = "Segoe UI"

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

        self.dict = Dictionary()

        self.kb = KnowledgeBase("clips.clp", self.dict)
        self.current_question = None
        self.ask_next_question()

    def ask_next_question(self):
        next_question = self.kb.get_next_question()

        if not next_question:
            self.go_back()
            return

        if next_question["type"] == "question":
            question = self.dict.get_full_question(next_question["id"])
            answers = [self.dict.get_full_answers(answer_id) for answer_id in next_question["answers"]]
            self.set_question(question, answers)
            self.current_question = next_question["id"]
        elif next_question["type"] == "recommendation":
            self.show_recommendation(next_question["id"], next_question["reason"])


    def set_question(self, question, answers):
        self.question_label.config(text=question)

        for b in self.buttons_frame.winfo_children():
            b.destroy()

        for i, label in enumerate(answers[:6]):
            row = i // 2
            col = i % 2
            btn = tk.Button(
                self.buttons_frame,
                command=(lambda l = label: self.on_answer(l)),
                text=label,
                width=50, height=5, wraplength=200,
                bg="#ffd966", activebackground="#ffe187",
                borderwidth=5, relief="ridge",
                font=(font_family, 9)
            )
            btn.grid(row=row, column=col, padx=5, pady=3)

    def on_answer(self, full_answer):
        answer_id = self.dict.get_answer_id(full_answer)
        self.kb.handle_user_answer(self.current_question, answer_id)
        self.ask_next_question()

    def go_back(self):
        self.kb.go_back()
        self.ask_next_question()

    def show_recommendation(self, rec_id, reason_id):
        self.question_label.config(text=f"{self.dict.get_full_reason(rec_id, reason_id)}")
        for b in self.buttons_frame.winfo_children():
            b.destroy()

class KnowledgeBase:
    def __init__(self, env_path, dictionary):
        self.env = clips.Environment()
        self.env.load(env_path)
        self.history = []

        self.dict = dictionary

    def get_next_question(self):
        self.env.run()

        for fact in self.env.facts():
            if fact.template.name == "request-input":
                return {
                    "type": "question",
                    "id": fact["id"],
                    "answers": list(fact["valid-answers"])
                }
            if fact.template.name == "recommendation":
                return {
                    "type": "recommendation",
                    "id": fact["id"],
                    "reason": fact["reason"]
                }

        return None

    def handle_user_answer(self, cur_question_id, answer_id):
        attr_name = self.dict.get_question_attribute(cur_question_id)
        for fact in self.env.facts():
            if fact.template.name == "request-input":
                fact.retract()
        self.env.assert_string(f"(attribute (name {attr_name}) (value {answer_id}))")
        self.history.append(answer_id)

    def go_back(self):
        if not self.history:
            return

        last_answer = self.history.pop()

        for fact in list(self.env.facts()):
            if fact.template.name == "attribute" and fact["value"] == last_answer:
                fact.retract()
            if fact.template.name in ("request-input", "recommendation"):
                fact.retract()

class Dictionary:
    def __init__(self, path="full.json"):
        with open(path) as f:
            data = json.load(f)
        self.questions = data["questions"]
        self.answers   = data["answers"]
        self.products  = data["products"]
        self.reasons   = data["reasons"]

    def get_full_question(self, question_id):
        if question_id in self.questions:
            return self.questions[question_id]["text"]
        return ""

    def get_question_attribute(self, question_id):
        if question_id in self.questions:
            return self.questions[question_id]["attribute"]
        return ""

    def get_full_answers(self, answer_id):
        if answer_id in self.answers:
            return self.answers[answer_id]
        return ""

    def get_answer_id(self, full_answer):
        for key, value in self.answers.items():
            if value == full_answer:
                return key
        return ""

    def get_full_reason(self, product_id, reason_id):
        full_reason = ""
        product_name = ""
        if reason_id in self.reasons:
            full_reason = self.reasons[reason_id]
        if product_id in self.products:
            product_name = self.products[product_id]
        return full_reason % product_name

if __name__ == "__main__":
    app = App()
    app.mainloop()
