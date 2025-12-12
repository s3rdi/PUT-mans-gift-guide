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
 
 
; =========================================================
; 3a. MALE -> DAD
; =========================================================
 
; What did you get him last holiday season?
(defrule ask-dad-history
   (attribute (name relation) (value val_dad))
   (not (attribute (name prev_gift)))
   =>
   (assert (request-input 
      (id q_dad_prev_gift)
      (valid-answers val_tie val_powertools val_mug val_grill)
   ))
)
 
; How original... How many ties does he own now?
(defrule ask-dad-tie-count
   (attribute (name relation) (value val_dad))
   (attribute (name prev_gift) (value val_tie))
   (not (attribute (name tie_count)))
   =>
   (assert (request-input 
      (id q_dad_tie_count)
      (valid-answers val_gt_75 val_lt_75)
   ))
)
 
; I think you can skip a year of the ties. How about this year you get him a gift that won't end up thrown in the back of the closet? Like a Holiday 4-Pack.
(defrule res-dad-too-many-ties
   (attribute (name relation) (value val_dad))
   (attribute (name prev_gift) (value val_tie))
   (attribute (name tie_count) (value val_gt_75))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_skip_ties)))
)
 
; I know you are worried that Dad needs another tie, but if he can go an entire month without wearing the same tie twice I think he is ok on ties. Let's go with a Holiday 4-Pack this year.
(defrule res-dad-not-so-many-ties
   (attribute (name relation) (value val_dad))
   (attribute (name prev_gift) (value val_tie))
   (attribute (name tie_count) (value val_lt_75))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_month_ties)))
)
 
; So Dad is pretty handy huh?
(defrule ask-dad-handy
   (attribute (name relation) (value val_dad))
   (attribute (name prev_gift) (value val_powertools))
   (not (attribute (name is_handy)))
   =>
   (assert (request-input (id q_dad_handy) (valid-answers val_yes val_no)))
)
 
; Then he already has all the tools he needs. Get him a Holiday 4-Pack this year.
(defrule res-dad-tools-handy
   (attribute (name relation) (value val_dad))
   (attribute (name is_handy) (value val_yes))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_has_tools)))
)
 
; Stop enabling this behavior and get him Holiday 4-Pack this year.
(defrule res-dad-tools-not-handy
   (attribute (name relation) (value val_dad))
   (attribute (name is_handy) (value val_no))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_stop_enabling)))
)
 
; And does he actually use this mug?
(defrule ask-dad-mug-usage
   (attribute (name relation) (value val_dad))
   (attribute (name prev_gift) (value val_mug))
   (not (attribute (name uses_mug)))
   =>
   (assert (request-input (id q_dad_mug_usage) (valid-answers val_yes val_no)))
)
 
; Here's what you do: "accidentally" drop the mug and get him a Holiday 4-Pack to make up for your clumsiness.
(defrule res-dad-mug-yes
   (attribute (name relation) (value val_dad))
   (attribute (name uses_mug) (value val_yes))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_break_mug)))
)
 
; Then get him a gift he will actually use... Like a Holiday 4-Pack.
(defrule res-dad-mug-no
   (attribute (name relation) (value val_dad))
   (attribute (name uses_mug) (value val_no))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_gift_he_uses)))
)
 
; Was he so excited to test out the new grill right away that almost started the house on fire?
(defrule ask-dad-grill-fire
   (attribute (name relation) (value val_dad))
   (attribute (name prev_gift) (value val_grill))
   (not (attribute (name almost_fire)))
   =>
   (assert (request-input (id q_dad_almost_fire) (valid-answers val_yes val_no)))
)
 
; For the rest of the family's safety you need to get him a gift that is not a fire hazard... Like a Holiday 4-Pack.
(defrule res-dad-grill
   (attribute (name relation) (value val_dad))
   (or
	(attribute (name almost_fire) (value val_yes))
	(attribute (name almost_fire) (value val_no))
   )
   =>
   (assert (recommendation (id res_4pack) (reason rsn_fire_hazard)))
)
 
 
; =========================================================
; 3b. MALE -> BROTHER
; =========================================================
 
; Younger or older?
(defrule ask-brother-age
   (attribute (name relation) (value val_brother))
   (not (attribute (name relative_age)))
   =>
   (assert (request-input (id q_relative_age) (valid-answers val_younger val_older)))
)
 
; So you probably picked on him when you were growing up?
(defrule ask-brother-younger-bullied
   (attribute (name relation) (value val_brother))
   (attribute (name relative_age) (value val_younger))
   (not (attribute (name bully_you)))
   =>
   (assert (request-input (id q_bullied) (valid-answers val_yes val_no)))
)
 
; Show him how much you've grown and make amends for your adolescent bullying by getting him a Holiday 4-Pack.
(defrule res-brother-younger-bully
   (attribute (name relative_age) (value val_younger))
   (attribute (name bully_you) (value val_yes))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_amends_bullying)))
)
 
; You are the best older brother ever! You have probably already bought him multiple Holiday 4-Packs.
(defrule res-brother-younger-nice
   (attribute (name relative_age) (value val_younger))
   (attribute (name bully_you) (value val_no))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_best_brother)))
)
 
; So he probably picked on you when you were growing up?
(defrule ask-brother-older-bullied
   (attribute (name relation) (value val_brother))
   (attribute (name relative_age) (value val_older))
   (not (attribute (name bully_him)))
   =>
   (assert (request-input (id q_bullied_you) (valid-answers val_yes val_no)))
)
 
; Here's what you do: Get him a Holiday 4-Pack, then get yourself a 10-Pack and passive-aggressively demonstrate your newfound superiority.
(defrule res-brother-older-noogie
   (attribute (name relative_age) (value val_older))
   (attribute (name bully_him) (value val_yes))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_superiority)))
)
 
; You have the best older brother ever! Get a pair of Holiday 4-Pack and enjoy some quality time with this great guy.
(defrule res-brother-older-nice
   (attribute (name relative_age) (value val_older))
   (attribute (name bully_him) (value val_no))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_best_older_brother)))
)
 
 
; =========================================================
; 3c. MALE -> UNCLE, CO-WORKER, FATHER-IN-LAW
; =========================================================
 
; Ah yes, Crazy Uncle Charlie... When was the last time you saw him?
(defrule ask-uncle-seen
   (attribute (name relation) (value val_uncle))
   (not (attribute (name seen_lately)))
   =>
   (assert (request-input (id q_uncle_seen) (valid-answers val_last_christmas val_thanksgiving val_last_week)))
)
 
; Last Christmas - He drank too much eggnog and passed out on the couch while watching basketball.
; A couple of weeks ago at Thanksgiving - He ate too much turkey and passed out on the couch while watching football.
; Last week when he invited himself over then passed out on the couch while watching 'Scandal'.
; Get him a Holiday 4-Pack and get him off your couch!
(defrule res-uncle-any
   (attribute (name relation) (value val_uncle))
   (attribute (name seen_lately) (value ?))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_get_off_couch)))
)
 
; Is this person your boss?
(defrule ask-is-boss
   (attribute (name relation) (value val_coworker))
   (not (attribute (name is_boss)))
   =>
   (assert (request-input (id q_is_boss) (valid-answers val_yes val_no)))
)
 
; No need to buy this person a gift. Take the money you would have spent and put it towards a Holiday 4-Pack of your own.
(defrule res-not-boss
   (attribute (name relation) (value val_coworker))
   (attribute (name is_boss) (value val_no))
   =>
   (assert (recommendation (id res_4pack_own) (reason rsn_no_need)))
)
 
; Do you like him?
(defrule ask-boss-like
   (attribute (name relation) (value val_coworker))
   (attribute (name is_boss) (value val_yes))
   (not (attribute (name boss_like)))
   =>
   (assert (request-input (id q_boss_like) (valid-answers val_yes val_no)))
)
 
; Get him a Holiday 4-Pack. Can you say 'promotion'?
(defrule res-boss-like
   (attribute (name relation) (value val_coworker))
   (attribute (name is_boss) (value val_yes))
   (attribute (name boss_like) (value val_yes))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_promotion)))
)
 
; Get him a Holiday 4-Pack consisting of 4 weekday, day games and enjoy the extra time he is out of the office.
(defrule res-boss-dont-like
   (attribute (name relation) (value val_coworker))
   (attribute (name is_boss) (value val_yes))
   (attribute (name boss_like) (value val_no))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_out_of_office)))
)
 
; Face it, you'll never be good enough for his daughter. Your best chance of redeeming yourself would be to get him a Holiday 4-Pack.
(defrule res-father-in-law
   (attribute (name relation) (value val_fatherinlaw))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_redeem_yourself)))
)
 
 
; =========================================================
; 4a. FEMALE -> WIFE/GIRLFRIEND
; =========================================================
 
; Is she a Brewers fan?
(defrule ask-partner-fan
   (or (attribute (name relation) (value val_wife))
       (attribute (name relation) (value val_girlfriend)))
   (not (attribute (name is_fan)))
   =>
   (assert (request-input (id q_is_fan) (valid-answers val_yes val_not_yet)))
)
 
; You have found yourself a true life partner. Get her a Holiday 4-Pack as a sign of your gratitude.
(defrule res-wife-fan-yes
   (attribute (name relation) (value val_wife))
   (attribute (name is_fan) (value val_yes))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_true_life_partner)))
)
 
; Nice, Bro! Get her a Holiday 4-Pack to make sure you don't screw this up
(defrule res-girl-fan-yes
   (attribute (name relation) (value val_girlfriend))
   (attribute (name is_fan) (value val_yes))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_girl_chance)))
)
 
; Dump her. But first give her a Holiday 4-Pack to soften the blow.
(defrule res-girl-fan-no
   (attribute (name relation) (value val_girlfriend))
   (attribute (name is_fan) (value val_not_yet))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_soften_blow)))
)
 
; That's unfortunate, but she'll come around. Have you considered buying her clothes?
(defrule ask-buy-clothes
   (attribute (name relation) (value val_wife))
   (attribute (name is_fan) (value val_not_yet))
   (not (attribute (name buy_clothes)))
   =>
   (assert (request-input (id q_buy_clothes) (valid-answers val_yes val_no)))
)
 
; Really? You should know by now that no woman actually wants a man picking out her clothes. Do you even know her size?
(defrule ask-her-size
   (attribute (name buy_clothes) (value val_yes))
   (not (attribute (name her_size)))
   =>
   (assert (request-input (id q_her_size) (valid-answers val_sure val_no_chance)))
)
 
; Oh boy, just get her the Holiday 4-Pack. Trust us, you'll thank us later.
(defrule res-her-size-sure
   (attribute (name her_size) (value val_sure))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_oh_boy)))
)
 
; Time to pull the plug on this little experiment and just get her a Holiday 4-Pack.
(defrule res-her-size-no
   (attribute (name her_size) (value val_no_chance))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_experiment)))
)
 
; Good decision. You know your limitations. Get her a Holiday 4-Pack and spend your next few weekends watching college football instead of braving shopping malls only to get her a shirt she will return anyway.
(defrule res-buy-clothes-no
   (attribute (name buy_clothes) (value val_no))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_free_weekends)))
)
 
; =========================================================
; 4b. FEMALE -> MOM
; =========================================================
 
; Is she a Brewers fan?
(defrule ask-mom-fan
   (attribute (name relation) (value val_mom))
   (not (attribute (name is_fan)))
   =>
   (assert (request-input (id q_is_fan) (valid-answers val_yes val_no_sports)))
)
 
; Obviously you got your brains from your mother. Earn the title of "favorite child" by getting her a Holiday 4-Pack.
(defrule res-mom-fan
   (attribute (name relation) (value val_mom))
   (attribute (name is_fan) (value val_yes))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_favorite_child)))
)
 
; What else does she like?
(defrule ask-mom-likes
   (attribute (name relation) (value val_mom))
   (attribute (name is_fan) (value val_no_sports))
   (not (attribute (name mom_likes)))
   =>
   (assert (request-input 
      (id q_mom_likes) 
      (valid-answers val_fun_day val_quality_time val_food val_ornaments)
   ))
)
 
; Well that was easy... Get her a Holiday 4-Pack. She can enjoy all of those things at Miller Park.
(defrule res-mom-any-no-ornaments
   (attribute (name relation) (value val_mom))
   (attribute (name mom_likes) (value val_fun_day|val_quality_time|val_food))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_miller_park)))
)
 
; Perfect! You get a free Bernie Brewer with every pair of Holiday 4-packs
(defrule res-mom-ornaments
   (attribute (name relation) (value val_mom))
   (attribute (name mom_likes) (value val_ornaments))
   =>
   (assert (recommendation (id res_4pack_ornament) (reason rsn_free_ornament)))
)
 
; =========================================================
; 4c. FEMALE -> MOTHER-IN-LAW
; =========================================================
 
; What does she really want for the holidays?
(defrule ask-motherinlaw-want
   (attribute (name relation) (value val_motherinlaw))
   (not (attribute (name really_wants)))
   =>
   (assert (request-input (id q_really_wants) (valid-answers val_cake val_plaque val_sweater val_poster)))
)
 
; For just a minute, forget about what she wants...
(defrule res-motherinlaw-want-any
   (attribute (name relation) (value val_motherinlaw))
   (attribute (name really_wants) (value ?))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_forget_ashamed)))
)
 
; =========================================================
; 4d. FEMALE -> SISTER
; =========================================================
 
; Younger or older?
(defrule ask-sister-age
   (attribute (name relation) (value val_sister))
   (not (attribute (name relative_age)))
   =>
   (assert (request-input (id q_relative_age) (valid-answers val_older val_younger)))
)
 
; The woman probably changed your diapers when you were a baby. You owe her BIG TIME. Get her a Holiday 4-Pack.
(defrule res-sister-older
   (attribute (name relation) (value val_sister))
   (attribute (name relative_age) (value val_older))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_changed_diapers)))
)
 
; Was she spoiled as a child?
(defrule ask-sister-spoiled
   (attribute (name relation) (value val_sister))
   (attribute (name relative_age) (value val_younger))
   (not (attribute (name is_spoiled)))
   =>
   (assert (request-input (id q_sister_spoiled) (valid-answers val_yes val_no)))
)
 
; You know you can't wait to see her face light up when she opens that Holiday 4-Pack. Just think of the memories you'll make.
(defrule res-sister-spoiled-any
   (attribute (name relation) (value val_sister))
   (attribute (name is_spoiled) (value ?))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_face_light_up)))
)
 
; =========================================================
; 4e. FEMALE -> CO-WORKER
; =========================================================
 
; Do you know anything about this person?
(defrule ask-coworker-knowledge
   (attribute (name relation) (value val_coworker))
   (not (attribute (name know_anything)))
   =>
   (assert (request-input (id q_know_anything) (valid-answers val_cat val_hat)))
)
 
; You could get her a cat toy... Of course, then she will know that you think she is the crazy cat lady. A Holiday 4-Pack is safer.
(defrule res-coworker-cat
   (attribute (name relation) (value val_coworker))
   (attribute (name know_anything) (value val_cat))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_safer_toy)))
)
 
; Get her a Holiday 4-Pack. You can never go wrong with that.
(defrule res-coworker-hat
   (attribute (name relation) (value val_coworker))
   (attribute (name know_anything) (value val_hat))
   =>
   (assert (recommendation (id res_4pack) (reason rsn_never_wrong)))
)