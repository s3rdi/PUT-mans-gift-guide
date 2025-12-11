; =========================================================
; 1. TEMPLATKI
; =========================================================

; Odpowiedź użytkownika
;
; name - nazwa atrybutu
; value - wartość atrybutu

(deftemplate attribute
   (slot name)
   (slot value)
)


; Request do GUI
;
; id - identyfikator pytania
; type - typ odpowiedzi
; valid-answers - lista odpowiedzi

(deftemplate request-input
   (slot id)
   (slot type (default single-choice))
   (multislot valid-answers)
)


; Wynik flowchartu
; id - identyfikator produktu (Holiday 4-Pack?)
; reason - uzasadnienie

(deftemplate recommendation
   (slot id)
   (slot reason)
)

; =========================================================
; 2. START
; =========================================================

; What is the gender of the person receiving your gift?
(defrule init-system
   ; brak pierwszego atrybutu (pytanie o płeć)
   (not (attribute (name gender)))
   =>
   ; pytanie startowe
   (assert (request-input 
      (id q_gender)
      (valid-answers val_male val_female)
   ))
)

; This is gonna be hard. Guys don't buy gifts for other guys. Why are you buying him a gift?
(defrule ask-relation-male
   (attribute (name gender) (value val_male))
   (not (attribute (name relation)))
   =>
   (assert (request-input 
      (id q_relation_male)
      (valid-answers val_dad val_brother val_uncle val_coworker val_fatherinlaw)
   ))
)

; Let's face it, you are in trouble. Why are you buying her a gift?
(defrule ask-relation-female
   (attribute (name gender) (value val_female))
   (not (attribute (name relation)))
   =>
   (assert (request-input 
      (id q_relation_female)
      (valid-answers val_wife val_girlfriend val_mom val_motherinlaw val_sister val_coworker_f)
   ))
)