//
//  CityTranslationService.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 29.09.25.
//

import Foundation

// MARK: - CityTranslationService
class CityTranslationService {
    // MARK: - Singleton
    static let shared = CityTranslationService()
    
    // MARK: - Private Properties
    private let cityTranslations: [String: String] = [
        // Russian cities
        "москва": "moscow",
        "санкт-петербург": "saint petersburg",
        "петербург": "saint petersburg",
        "спб": "saint petersburg",
        "новосибирск": "novosibirsk",
        "екатеринбург": "yekaterinburg",
        "казань": "kazan",
        "нижний новгород": "nizhny novgorod",
        "челябинск": "chelyabinsk",
        "самара": "samara",
        "омск": "omsk",
        "ростов-на-дону": "rostov-on-don",
        "уфа": "ufa",
        "красноярск": "krasnoyarsk",
        "пермь": "perm",
        "воронеж": "voronezh",
        "волгоград": "volgograd",
        "краснодар": "krasnodar",
        "саратов": "saratov",
        "тюмень": "tyumen",
        
        // CIS cities
        "минск": "minsk",
        "киев": "kiev",
        "алматы": "almaty",
        "ташкент": "tashkent",
        "баку": "baku",
        "ереван": "yerevan",
        "тбилиси": "tbilisi",
        "батуми": "batumi",
        "астана": "astana",
        "бишкек": "bishkek",
        "душанбе": "dushanbe",
        "ашхабад": "ashgabat",
        "кишинёв": "chisinau",
        
        // European cities
        "рига": "riga",
        "вильнюс": "vilnius",
        "таллинн": "tallinn",
        "варшава": "warsaw",
        "краков": "krakow",
        "гданьск": "gdansk",
        "будапешт": "budapest",
        "братислава": "bratislava",
        "любляна": "ljubljana",
        "загреб": "zagreb",
        "белград": "belgrade",
        "подгорица": "podgorica",
        "сараево": "sarajevo",
        "скопье": "skopje",
        "софия": "sofia",
        "бухарест": "bucharest",
        "лондон": "london",
        "париж": "paris",
        "берлин": "berlin",
        "рим": "rome",
        "мадрид": "madrid",
        "амстердам": "amsterdam",
        "вена": "vienna",
        "прага": "prague",
        "стокгольм": "stockholm",
        "хельсинки": "helsinki",
        "копенгаген": "copenhagen",
        "осло": "oslo",
        "дублин": "dublin",
        "лиссабон": "lisbon",
        "брюссель": "brussels",
        "цюрих": "zurich",
        "женева": "geneva",
        "барселона": "barcelona",
        "милан": "milan",
        "венеция": "venice",
        "флоренция": "florence",
        "неаполь": "naples",
        "палермо": "palermo",
        "турин": "turin",
        "болонья": "bologna",
        "лион": "lyon",
        "марсель": "marseille",
        "ницца": "nice",
        "тулуза": "toulouse",
        "страсбург": "strasbourg",
        "мюнхен": "munich",
        "франкфурт": "frankfurt",
        "гамбург": "hamburg",
        "кёльн": "cologne",
        "дюссельдорф": "dusseldorf",
        "штутгарт": "stuttgart",
        "дортмунд": "dortmund",
        "эссен": "essen",
        "дрезден": "dresden",
        "лейпциг": "leipzig",
        "нюрнберг": "nuremberg",
        "ганновер": "hannover",
        "бремен": "bremen",
        "манчестер": "manchester",
        "бирмингем": "birmingham",
        "глазго": "glasgow",
        "эдинбург": "edinburgh",
        "ливерпуль": "liverpool",
        "лидс": "leeds",
        "шеффилд": "sheffield",
        "бристоль": "bristol",
        "кардифф": "cardiff",
        "белфаст": "belfast",
        "валенсия": "valencia",
        "севилья": "seville",
        "бильбао": "bilbao",
        "сарагоса": "zaragoza",
        "малага": "malaga",
        "пальма": "palma",
        "гранада": "granada",
        "кордова испания": "cordoba spain",
        "сантьяго-де-компостела": "santiago de compostela",
        "порту": "porto",
        "авейру": "aveiro",
        "фару": "faro",
        "рейкьявик": "reykjavik",
        "берген": "bergen",
        "тронхейм": "trondheim",
        "ставангер": "stavanger",
        "гётеборг": "gothenburg",
        "мальмё": "malmo",
        "упсала": "uppsala",
        "оденсе": "odense",
        "орхус": "aarhus",
        "хельсингёр": "helsingor",
        "роскилле": "roskilde",
        "афины": "athens",
        "салоники": "thessaloniki",
        "патры": "patras",
        "ираклион": "heraklion",
        "родос": "rhodes",
        "миконос": "mykonos",
        "санторини": "santorini",
        "лутраки": "loutraki",
        
        // Asian cities
        "пекин": "beijing",
        "шанхай": "shanghai",
        "токио": "tokyo",
        "сеул": "seoul",
        "бангкок": "bangkok",
        "сингапур": "singapore",
        "куала-лумпур": "kuala lumpur",
        "джакарта": "jakarta",
        "манила": "manila",
        "ханой": "hanoi",
        "хошимин": "ho chi minh city",
        "дели": "delhi",
        "мумбаи": "mumbai",
        "калькутта": "kolkata",
        "ченнай": "chennai",
        "бангалор": "bangalore",
        "дубай": "dubai",
        "абу-даби": "abu dhabi",
        "доха": "doha",
        "эр-рияд": "riyadh",
        "кувейт": "kuwait city",
        "тель-авив": "tel aviv",
        "иерусалим": "jerusalem",
        "анкара": "ankara",
        "стамбул": "istanbul",
        "измир": "izmir",
        "тегеран": "tehran",
        "исфахан": "isfahan",
        "кабул": "kabul",
        "карачи": "karachi",
        "лахор": "lahore",
        "исламабад": "islamabad",
        "дакка": "dhaka",
        "читтагонг": "chittagong",
        "коломбо": "colombo",
        "катманду": "kathmandu",
        "улан-батор": "ulaanbaatar",
        
        // American cities
        "нью-йорк": "new york",
        "лос-анджелес": "los angeles",
        "чикаго": "chicago",
        "хьюстон": "houston",
        "филадельфия": "philadelphia",
        "финикс": "phoenix",
        "сан-антонио": "san antonio",
        "сан-диего": "san diego",
        "даллас": "dallas",
        "сан-хосе сша": "san jose",
        "остин": "austin",
        "джексонвилл": "jacksonville",
        "сан-франциско": "san francisco",
        "колумбус": "columbus",
        "шарлотт": "charlotte",
        "форт-уэрт": "fort worth",
        "детройт": "detroit",
        "эль-пасо": "el paso",
        "мемфис": "memphis",
        "сиэтл": "seattle",
        "денвер": "denver",
        "вашингтон": "washington",
        "бостон": "boston",
        "нашвилл": "nashville",
        "балтимор": "baltimore",
        "оклахома-сити": "oklahoma city",
        "луисвилл": "louisville",
        "портленд": "portland",
        "лас-вегас": "las vegas",
        "милуоки": "milwaukee",
        "альбукерке": "albuquerque",
        "тусон": "tucson",
        "фресно": "fresno",
        "сакраменто": "sacramento",
        "канзас-сити": "kansas city",
        "меса": "mesa",
        "атланта": "atlanta",
        "омаха": "omaha",
        "колорадо-спрингс": "colorado springs",
        "роли": "raleigh",
        "майами": "miami",
        "кливленд": "cleveland",
        "тампа": "tampa",
        "новый орлеан": "new orleans",
        "миннеаполис": "minneapolis",
        "арлингтон": "arlington",
        "хонолулу": "honolulu",
        "санта-ана": "santa ana",
        "сент-луис": "st. louis",
        "питтсбург": "pittsburgh",
        
        // Canadian cities
        "торонто": "toronto",
        "ванкувер": "vancouver",
        "монреаль": "montreal",
        "калгари": "calgary",
        "эдмонтон": "edmonton",
        "оттава": "ottawa",
        "виннипег": "winnipeg",
        "квебек": "quebec city",
        "галифакс": "halifax",
        
        // Latin American cities
        "мехико": "mexico city",
        "канкун": "cancun",
        "гвадалахара": "guadalajara",
        "монтеррей": "monterrey",
        "буэнос-айрес": "buenos aires",
        "кордова аргентина": "cordoba",
        "мендоса": "mendoza",
        "сан-паулу": "sao paulo",
        "рио-де-жанейро": "rio de janeiro",
        "бразилиа": "brasilia",
        "белу-оризонти": "belo horizonte",
        "лима": "lima",
        "куско": "cusco",
        "богота": "bogota",
        "медельин": "medellin",
        "картахена": "cartagena",
        "каракас": "caracas",
        "кито": "quito",
        "гуаякиль": "guayaquil",
        "ла-пас": "la paz",
        "санта-крус": "santa cruz",
        "сантьяго": "santiago",
        "вальпараисо": "valparaiso",
        "монтевидео": "montevideo",
        "асунсьон": "asuncion",
        "панама": "panama city",
        "сан-хосе коста-рика": "san jose costa rica",
        "сан-сальвадор": "san salvador",
        "тегусигальпа": "tegucigalpa",
        "манагуа": "managua",
        "гватемала": "guatemala city",
        "белиз": "belize city",
        "гавана": "havana",
        "кингстон": "kingston",
        "санто-доминго": "santo domingo",
        "сан-хуан": "san juan",
        
        // African cities
        "каир": "cairo",
        "александрия": "alexandria",
        "касабланка": "casablanca",
        "рабат": "rabat",
        "марракеш": "marrakech",
        "тунис": "tunis",
        "алжир": "algiers",
        "триполи": "tripoli",
        "лагос": "lagos",
        "абуджа": "abuja",
        "аккра": "accra",
        "абиджан": "abidjan",
        "дакар": "dakar",
        "бамако": "bamako",
        "найроби": "nairobi",
        "мombasa": "mombasa",
        "дар-эс-салам": "dar es salaam",
        "кампала": "kampala",
        "кигали": "kigali",
        "аддис-абеба": "addis ababa",
        "йоханнесбург": "johannesburg",
        "кейптаун": "cape town",
        "дурбан": "durban",
        "претория": "pretoria",
        "виндхук": "windhoek",
        "габороне": "gaborone",
        "мапуту": "maputo",
        "лусака": "lusaka",
        "хараре": "harare",
        "антананариву": "antananarivo",
        
        // Oceanic cities
        "сидней": "sydney",
        "мельбурн": "melbourne",
        "брисбен": "brisbane",
        "перт": "perth",
        "аделаида": "adelaide",
        "канберра": "canberra",
        "окленд": "auckland",
        "веллингтон": "wellington",
        "крайстчерч": "christchurch",
        "сува": "suva",
        "нуку-алофа": "nuku alofa",
        "апиа": "apia",
        "порт-вила": "port vila"
    ]
    
    // MARK: - lazy computed
    private lazy var reverseTranslations: [String: String] = {
        var reverse: [String: String] = [:]
        for (russian, english) in cityTranslations {
            reverse[english.lowercased()] = russian
        }
        return reverse
    }()
    
    // MARK: - Init
    private init() {
        AppLogger.shared.info("CityTranslationService initialized", category: .data, metadata: [
            "translations_count": cityTranslations.count
        ])
    }
    
    // MARK: - Public Methods
    func translateToEnglish(russianCityName: String) -> String? {
        let lowercaseName = russianCityName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return cityTranslations[lowercaseName]
    }
   
    func translateToRussian(englishCityName: String) -> String? {
        let lowercaseName = englishCityName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return reverseTranslations[lowercaseName]?.capitalized
    }
    
    func isTranslationSupported(for cityName: String) -> Bool {
        let lowercaseName = cityName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return cityTranslations[lowercaseName] != nil || reverseTranslations[lowercaseName] != nil
    }

    func getSupportedRussianCities() -> [String] {
        return Array(cityTranslations.keys).map { $0.capitalized }.sorted()
    }
    
    func getSupportedEnglishCities() -> [String] {
        return Array(Set(cityTranslations.values)).sorted()
    }
    
    func searchCities(query: String) -> [(russian: String, english: String)] {
        let lowercaseQuery = query.lowercased()
        var results: [(russian: String, english: String)] = []
        
        for (russian, english) in cityTranslations {
            if russian.contains(lowercaseQuery) || english.lowercased().contains(lowercaseQuery) {
                results.append((russian: russian.capitalized, english: english))
            }
        }
        
        return results.sorted { $0.russian < $1.russian }
    }
}
