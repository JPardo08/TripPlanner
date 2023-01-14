;;**
;;* DEFFUNCTIONS *
;;**

(deffunction ask-question (?question $?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer) 
       then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer) 
          then (bind ?answer (lowcase ?answer))))
   ?answer)

 
(deffunction yes-or-no-idk (?question)
   (bind ?response (ask-question ?question yes no idk y n i))
   (if (or (eq ?response yes) (eq ?response y)) then
          yes
    else
          (if (or (eq ?response no) (eq ?response n)) then
                 no
           else
                 idk)))

(deffunction high-or-low-medium (?question)
   (bind ?response (ask-question ?question high low medium h l m))
   (if (or (eq ?response high) (eq ?response h)) then
          high
    else
          (if (or (eq ?response medium) (eq ?response m)) then
                 medium
           else
                 low)))


;;;***************
;;;* QUERY RULES FOR COMPANIONS*
;;;***************

(defrule determine-companions ""
	(not (companions ?))
	=> 
	(assert (companions (yes-or-no-idk "Llevaras acompanantes (yes/no/idk)?)"))))

(defrule determine-age "Cuando no lleva compañeros preguntamos su edad"
	(companions no)
	(not (age ?))
	=> 
	(assert (age (ask-question "En que rango de edad estas (high - [>50]/medium - [30-50]/low - [<30])?)"
				    high medium low))))

(defrule determine-quantity-companions "En que rango de compañeros te encuentras"
	(companions yes)
	(not (companions-quantity ?))
	=> 
	(assert (companions-quantity
		(ask-question "Que cantidad de acompañantes llevas (high - [>=5]/medium - [2-4]/low - [1])?)"
				    high medium low))))

(defrule determine-ambit-companions "De que ambito de acompañantes es"
	(companions yes)
	(not (companions-ambit ?))
	=> 
	(assert (companions-ambit
		(ask-question "De que ambito son los acompañantes (amigos/familia/trabajo)?)"
				    amigos familia trabajo))))

(defrule determine-kids "Cuando los acompañantes son familia, saber si son niños"
	(companions yes)
	(companions-ambit familia)
	(not (kids ?))
	=> 
	(assert (kids (yes-or-no-idk"Hay niños en el grupo (yes/no/idk)?)"))))

(defrule determine-medium-age ""
	(companions yes)
	(or (companions-ambit amigos)
	    (companions-ambit trabajo))
	(not (medium-age ?))
	=> 
	(assert (medium-age (ask-question "En que rango de edad esta la edad media del grupo (high - [>50]/medium - [30-50]/low - [<30])?)"
				    high medium low))))
(defrule kids-age ""
	(companions yes)
	(kids yes)
	(not (kids-age ?))
	=> 
	(assert (kids-age (ask-question "Que edad tienen los niños (low [<=10] / high [>10])?)"
				    high low))))

(defrule kids-restrictions ""
	(companions yes)
	(kids yes)
	(kids-age low)
	(not (kid-restrictions ?))
	=> 
	(assert (kid-restrictions (yes-or-no-idk "Tiene algun niño alguna restriccion (yes/no/idk)?)"))))

(defrule determine-budget "Que presupuesto tiene el usuario"
	(not (budget ?))
	=> 
	(assert (budget (ask-question "En que rango de presupuesto te encuentras 
						(high - [>10k]/medium - [5k-10k]/low - [<5k])?)"
				    high medium low))))

;;;***************
;;;* QUERY RULES FOR HOSTING*
;;;***************

(defrule determine-hosting-type ""
	(not (hosting-type ?))
	=> 
	(assert (hosting-type
		(ask-question "Que tipo de alojamiento quieres (adosado/hotel/habitacion/hostal/apartamento)?)"
				    adosado hotel habitaciones hostal apartamento))))

(defrule determine-hosting-budget "Que presupuesto tiene el usuario para el alojamiento"
	(not (hosting-budget ?))
	=> 
	(assert (hosting-budget(ask-question "En que rango de presupuesto te encuentras para el alojamiento
						(high - [>5k]/medium - [2k-5k]/low - [<2k])?)"
				    high medium low))))


;;;***************
;;;* QUERY RULES FOR DURATION*
;;;***************


(defrule determine-duration ""
	(not (duration ?))
	=> 
	(assert (duration
		(ask-question "Como de larga van a ser tus vacaciones (large - [1 mes]/medium - [15 dias]/short- [Fin de semana])?)"
				    large medium short))))


;;;***************
;;;* QUERY RULES FOR TOURISM*
;;;***************


(defrule tourism ""
	(not (tourism ?))
	=> 
	(assert (tourism (yes-or-no-idk "Quiere realizar turismo en sus vacaciones (yes/no/idk)?)"))))

(defrule tourism-guide ""
	(tourism yes)
	=> 
	(assert (tourism-guide (yes-or-no-idk "Quiere un guia para el turismo en sus vacaciones (yes/no/idk)?)"))))

(defrule distance-tourism ""
	(tourism yes)
	(not (tourism-distance ?))
	=> 
	(assert (tourism-distance(yes-or-no-idk "Te da igual la distancia que se recorra haciendo turismo (yes/no/idk)?)"))))


(defrule determine-tourism-budget "Que presupuesto tiene el usuario"
	(tourism yes)
	(not (tourism-budget ?))
	=> 
	(assert (tourism-budget(ask-question "En que rango de presupuesto te encuentras 
						(high - [>1k]/medium - [0.5k-1k]/low - [<0.5k])?)"
				    high medium low))))

(defrule tourism-types-high ""
	(tourism yes)
	(tourism-budget high)
	(not (tourism-types-high ?))
	=>
	(assert (tourism-types-high(ask-question "Que tipo de turismo quieres realizar 
						(coche-alta-gama / tiendas-lujo / spa-lujo / ocio-nocturno-caro) ?)"
				    coche-alta-gama tiendas-lujo spa-lujo ocio-nocturno-caro))))ç

(defrule tourism-types-medium ""
	(tourism yes)
	(tourism-budget medium)
	(not (tourism-types-medium ?))
	=>
	(assert (tourism-types-medium(ask-question "Que tipo de turismo quieres realizar 
						(museo / tiendas / spa / ocio-nocturno-medio) ?)"
				    museo tiendas spa ocio-nocturno-medio))))

(defrule tourism-types-low ""
	(tourism yes)
	(tourism-budget low)
	(not (tourism-types-low ?))
	=>
	(assert (tourism-types-low(ask-question "Que tipo de turismo quieres realizar 
						(visitar-plaza / parques / monumentos / ocio-nocturno-barato) ?)"
				    visitar-plaza parques monumentos ocio-nocturno-barato))))

;;;***************
;;;* QUERY RULES FOR VEHICLE*
;;;***************

(defrule determine-vehicle""
	(not (vehicle ?))
	=> 
	(assert (vehicle (yes-or-no-idk "Necesitas vehiculo para tus vacaciones (yes/no/idk)?)"))))


(defrule personal-vehicle""
	(vehicle yes)
	(not (personal-vehicle ?))
	=> 
	(assert (personal-vehicle (ask-question "Es tu vehiculo personal o quieres alquiler (personal / alquiler) ?)"
				    personal alquiler))))

(defrule personal-vehicle-budget""
	(vehicle yes)
	(personal-vehicle personal)
	(not (personal-vehicle-budget ?))
	=> 
	(assert (personal-vehicle-budget (ask-question "Cual es tu presupuesto para gasolina (high - [>500E.]/medium - [300E.-500E.]/low - [<300E.])?)"
				    high medium low))))

(defrule alquiler-vehicle-type""
	(vehicle yes)
	(personal-vehicle alquiler)
	(not (alquiler-vehicle-type ?))
	=> 
	(assert (alquiler-vehicle-type (ask-question "Que tipo de vehiculo quieres alquilar (moto / coche / furgoneta)?)"
				    moto coche furgoneta))))


(defrule alquiler-vehicle-budget""
	(vehicle yes)
	(personal-vehicle alquiler)
	(not (alquiler-vehicle-budget ?))
	=> 
	(assert (alquiler-vehicle-budget (ask-question "Cual es tu presupuesto para el alquiler (high - [>500E.]/medium - [200E.-500E.]/low - [<200E.])?)"
				    high medium low))))


;;;***************
;;;* QUERY RULES FOR FOOD*
;;;***************


(defrule food-type""
	(not (food-type ?))
	=> 
	(assert (food-type (ask-question "Que tipo de comida quieres para tus vacaciones (restaurante / casera / hibrida) ?)"
				    restaurante casera hibrida))))


(defrule restaurant-food-type""
	(or (food-type restaurante)
		(food-type hibrida))
	(not (restaurant-food-type ?))
	=> 
	(assert (restaurant-food-type (ask-question "A que tipo de restaurante quieres ir en tus vacaciones (italiano / mexicano / espanola / turco) ?)"
		italiano mexicano espanola turco))))


(defrule hybrid-food-horario""
	(food-type hibrida)
	(not (hybrid-food-horario ?))
	=> 
	(assert (hybrid-food-horario (ask-question "Vas a comer o a cenar fuera (comer / cenar) ?)"
		comer cenar))))


(defrule food-budget""
	(not (food-budget ?))
	=> 
	(assert (food-budget (ask-question "Cual es tu presupuesto para comer (high - [>500E.]/medium - [200E.-500E.]/low - [<200E.])?)"
				    high medium low))))
	


;;;********************************
;;;* RULES FOR SELECT LOCATION OF VACATIONS
;;;********************************

(defrule case-uno ""
	(companions yes)
	(companions-quantity high)
	(companions-ambit amigos)
	(medium-age low)
	(budget low)
	(hosting-type hostal)
	(hosting-budget low)
	(duration medium)
	(tourism yes)
	(tourism-guide no)
	(tourism-distance idk)
	(tourism-budget low)
	(tourism-types-low ocio-nocturno-barato)
	(vehicle yes)
	(personal-vehicle personal)
	(personal-vehicle-budget low)
	(food-type hibrida)
	(restaurant-food-type italiano)
	(hybrid-food-horario cenar)
	(food-budget medium)
	=>
	(printout t crlf crlf)
	(printout t "Nuestra recomendacion es que vayas de vacaciones a Cuenca, te hospedaras en un hostal barato
			, vuestro turismo consistira en ocio nocturno en lugares baratos, 
	llevareis vuestro propio vehiculo y cenareis se en un italiano de buena calidad donde no os gatareis mucho dinero."))

(defrule case-dos ""
	(companions yes)
	(companions-quantity medium)
	(companions-ambit familia)
	(kids yes)
	(kids-age high)
	(budget medium)
	(hosting-type hotel)
	(hosting-budget medium)
	(duration medium)
	(tourism idk)
	(vehicle idk)
	(food-type casera)
	(food-budget medium)
	=>
	(printout t crlf crlf)
	(printout t "Nuestra recomendacion es que vayas de vacaciones a Gandia, te hospedaras en un hotel de 3 estrellas
			, en el caso que querais hacer turismo se os facilitara un mapa de los monumentos de la ciudad, en el caso de que no lleveis vuestro vehiculo personal
			se os dara la direccion para alquilar uno y comereis y cenareis en el hotel. "))


(defrule case-tres ""
	(companions no)
	(age high)
	(budget high)
	(hosting-type hotel)
	(hosting-budget high)
	(duration large)
	(tourism idk)
	(vehicle yes)
	(personal-vehicle alquiler)
	(alquiler-vehicle-type coche)
	(alquiler-vehicle-budget high)
	(food-type restaurante )
	(restaurant-food-type espanola)
	(food-budget high)
	=>
	(printout t crlf crlf)
	(printout t "Nuestra recomendacion es que vayas de vacaciones a Marbella, te hospedaras en un hostal de 5 estrellas
			,en el caso que quieras hacer turismo la agencia estara a tu disposicion, se os facilitara un coche de alta gama de alquiler y
			y comereis y cenareis en el mejor restaurante de la ciudad de comida espanola. "))


