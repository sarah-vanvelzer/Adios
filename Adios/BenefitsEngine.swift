import Foundation

enum BenefitVibe: Equatable {
    case funny, punchy, smart, reassuring
}

struct BenefitLine {
    let text: String
    let vibe: BenefitVibe
}

struct BenefitsEngine {

    static func benefits(for input: String) -> [String] {
        let query = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return globalFallback(count: 3) }

        var collected: [BenefitLine] = []

        for category in categories {
            guard category.keywords.contains(where: { matches(query, keyword: $0) }) else { continue }

            let specificLines = category.specificFoods
                .filter { food in food.keywords.contains(where: { matches(query, keyword: $0) }) }
                .flatMap { $0.lines }

            collected.append(contentsOf: specificLines.isEmpty ? category.fallback : specificLines)
        }

        if collected.isEmpty {
            return globalFallback(count: 3)
        }

        return pickDiverse(from: collected, count: 3).map { $0.text }
    }

    // MARK: MATCHING

    private static func matches(_ text: String, keyword: String) -> Bool {
        guard text.contains(keyword) else { return false }
        if keyword.contains(" ") { return true }
        let sep = CharacterSet.alphanumerics.inverted
        var range = text.startIndex..<text.endIndex
        while let r = text.range(of: keyword, range: range) {
            let beforeOK = r.lowerBound == text.startIndex
                || sep.contains(text[text.index(before: r.lowerBound)].unicodeScalars.first!)
            let afterOK: Bool
            if r.upperBound == text.endIndex {
                afterOK = true
            } else {
                let next = text[r.upperBound]
                let afterNext: Character? = text.index(after: r.upperBound) < text.endIndex
                    ? text[text.index(after: r.upperBound)] : nil
                let isS  = next == "s" && (afterNext == nil || !afterNext!.isLetter)
                let isEs = next == "e" && afterNext == "s"
                afterOK  = sep.contains(next.unicodeScalars.first!) || isS || isEs
            }
            if beforeOK && afterOK { return true }
            range = r.upperBound..<text.endIndex
        }
        return false
    }

    // MARK: VIBE SHUFFLE

    private static func pickDiverse(from pool: [BenefitLine], count: Int) -> [BenefitLine] {
        var result: [BenefitLine] = []
        var usedVibes: [BenefitVibe] = []
        var usedTexts = Set<String>()
        let shuffled = pool.shuffled()

        for line in shuffled {
            if result.count == count { break }
            if !usedTexts.contains(line.text) && !usedVibes.contains(line.vibe) {
                result.append(line)
                usedVibes.append(line.vibe)
                usedTexts.insert(line.text)
            }
        }
        for line in shuffled {
            if result.count == count { break }
            if !usedTexts.contains(line.text) {
                result.append(line)
                usedTexts.insert(line.text)
            }
        }
        return result
    }

    private static func globalFallback(count: Int) -> [String] {
        pickDiverse(from: globalLines, count: count).map { $0.text }
    }

    // MARK: GLOBAL FALLBACKS

    private static let globalLines: [BenefitLine] = [
        .init(text: "Your body asked & you answered.", vibe: .reassuring),
        .init(text: "Fed > perfect.", vibe: .punchy),
        .init(text: "That was a power move, actually.", vibe: .funny),
        .init(text: "Your metabolism says thank you.", vibe: .funny),
        .init(text: "You showed up for yourself today.", vibe: .reassuring),
        .init(text: "That's how you take care of future you.", vibe: .reassuring),
        .init(text: "Your nervous system appreciates the consistency.", vibe: .smart),
        .init(text: "Fuel is fuel, & you gave your body some.", vibe: .punchy),
        .init(text: "This is what sustainable looks like.", vibe: .reassuring),
        .init(text: "Your body is working hard, & you just helped.", vibe: .reassuring),
    ]

    // MARK: SPECIFIED CATEGORIES

    private struct SpecificFood {
        let keywords: [String]
        let lines: [BenefitLine]
    }

    private struct Category {
        let keywords: [String]
        let specificFoods: [SpecificFood]
        let fallback: [BenefitLine]
    }

    private static let categories: [Category] = [

        // FRUITS
        Category(
            keywords: [
                "fruit", "apple", "banana", "orange", "mango", "pineapple", "grape",
                "strawberry", "strawberries", "blueberry", "blueberries", "raspberry", "blackberry", "cherry",
                "cherries", "berry", "berries", "peach", "pear", "plum", "kiwi", "watermelon",
                "melon", "cantaloupe", "papaya", "lychee", "passion fruit", "guava", "fig",
                "apricot", "nectarine", "pomegranate", "dragonfruit", "dragon fruit", "persimmon",
                "clementine", "tangerine", "lemon", "lime", "grapefruit", "coconut",
                "avocado", "avo", "date", "raisin"
            ],
            specificFoods: [
                SpecificFood(keywords: ["apple"], lines: [
                    .init(text: "Pectin in apples feeds the good bacteria that run your brain.", vibe: .smart),
                    .init(text: "Natural sugar + fibre = energy that doesn't crash.", vibe: .punchy),
                    .init(text: "Apples are basically a battery pack in fruit form.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["banana"], lines: [
                    .init(text: "Potassium from bananas is what your heart literally runs on.", vibe: .smart),
                    .init(text: "That post-banana calm is real... your nervous system saying thanks.", vibe: .reassuring),
                    .init(text: "Bananas are one of the fastest ways to restore energy.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["pear"], lines: [
                    .init(text: "Pears have more fibre per serving than almost any other fruit.", vibe: .smart),
                    .init(text: "Slow-release sugar that keeps your energy even without the crash.", vibe: .punchy),
                    .init(text: "Copper in pears quitely supports your immune system.", vibe: .reassuring),
                    .init(text: "Pears are basically the most underrated fruit going.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["mango"], lines: [
                    .init(text: "Vitamin C in mango is doing serious immune work.", vibe: .smart),
                    .init(text: "Mango is basically sunshine in food form.", vibe: .funny),
                    .init(text: "Folate in mango supports cell growth & mood regulation.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["strawberry", "strawberries"], lines: [
                    .init(text: "More vitamin C per serving than an orange & nobody talks about it.", vibe: .funny),
                    .init(text: "Antioxidants in strawberries protect your brain from oxidative stress.", vibe: .smart),
                    .init(text: "Low sugar, high flavour, maximum impact.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["blueberry", "blueberries"], lines: [
                    .init(text: "Blueberries have one of the highest antioxidant counts of any food.", vibe: .smart),
                    .init(text: "Anthocyanins in blueberries literally improve memory.", vibe: .smart),
                    .init(text: "Tiny but absolutely delivering.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["berry", "berries", "raspberry", "raspberries", "blackberry", "blackberries"], lines: [
                    .init(text: "Anthocyanins in berries are some of the most powerful antioxidants in any food.", vibe: .smart),
                    .init(text: "Berries improve memory & brain function, the research is pretty convincing.", vibe: .smart),
                    .init(text: "Low sugar, insane nutrient density. Berries are punching above their weight.", vibe: .punchy),
                    .init(text: "Your gut bacteria genuinely thrive on berry polyphenols.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["avocado", "avo"], lines: [
                    .init(text: "Monounsaturated fat in avocado supports your heart.", vibe: .smart),
                    .init(text: "More potassium than a banana & nobody's talking about it.", vibe: .funny),
                    .init(text: "Avocado makes every other food more nutritious (fat = better absorption).", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["watermelon", "melon", "cantaloupe"], lines: [
                    .init(text: "92% water... your hydration just got a major upgrade.", vibe: .punchy),
                    .init(text: "Lycopene in watermelon is one of the most powerful antioxidants going.", vibe: .smart),
                    .init(text: "Hydration + nutrients in one hit, honestly iconic.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["cherry", "cherries"], lines: [
                    .init(text: "Melatonin in cherries genuinely supports better sleep.", vibe: .smart),
                    .init(text: "Deep red = serious antioxidant density.", vibe: .punchy),
                    .init(text: "Cherries help reduce post-exercise muscle soreness.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["orange", "clementine", "tangerine"], lines: [
                    .init(text: "Vitamin C is what converts iron into usable energy.", vibe: .smart),
                    .init(text: "Citrus is one of the fastest natural mood lifters going.", vibe: .punchy),
                    .init(text: "The acidity kickstarts digestion from the first bite.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["coconut"], lines: [
                    .init(text: "MCTs in coconut convert to energy faster than almost any fat.", vibe: .smart),
                    .init(text: "Coconut is doing more for your energy than it gets credit for.", vibe: .reassuring),
                    .init(text: "Electrolytes in coconut water are genuinely close to what's in your blood.", vibe: .smart),
                ]),
                SpecificFood(keywords: ["date", "raisin"], lines: [
                    .init(text: "Iron, potassium, magnesium... dates are basically a multivitamin.", vibe: .punchy),
                    .init(text: "Fibre in dates feeds good gut bacteria which shapes your mood.", vibe: .smart),
                    .init(text: "One of the most nutrient-dense natural sweeteners going.", vibe: .reassuring),
                ]),
            ],
            fallback: [
                .init(text: "Fruit delivers vitamins your body genuinely can't make on its own.", vibe: .smart),
                .init(text: "Natural sugar + fibre = energy that actually lasts.", vibe: .punchy),
                .init(text: "Fruit is basically your immune system's favourite thing.", vibe: .funny),
                .init(text: "Whatever fruit you're eating, your gut is grateful.", vibe: .reassuring),
            ]
        ),

        // VEGETABLES
        Category(
            keywords: [
                "vegetable", "veggie", "veg", "broccoli", "broccolini", "carrot",
                "spinach", "kale", "lettuce", "arugula", "rocket", "chard",
                "celery", "cucumber", "zucchini", "courgette", "pepper", "capsicum",
                "tomato", "potato", "sweet potato", "yam", "corn", "sweetcorn",
                "pea", "green bean", "asparagus", "artichoke", "eggplant", "aubergine",
                "cauliflower", "cabbage", "brussels sprout", "beet", "beetroot",
                "radish", "turnip", "leek", "onion", "garlic", "ginger",
                "mushroom", "squash", "butternut", "pumpkin", "fennel", "parsnip",
                "watercress", "bok choy", "pak choi"
            ],
            specificFoods: [
                SpecificFood(keywords: ["broccoli", "broccolini"], lines: [
                    .init(text: "Sulforaphane in broccoli is one of the most studied anti-cancer compounds going.", vibe: .smart),
                    .init(text: "Broccoli activates your body's natural detox enzymes.", vibe: .smart),
                    .init(text: "Literally top-tier inflammation control.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["carrot"], lines: [
                    .init(text: "Beta-carotene converts to vitamin A for eye & skin health.", vibe: .smart),
                    .init(text: "Carrots keep digestion moving without drama.", vibe: .funny),
                    .init(text: "Packed with micronutrients to support skin & immune health.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["spinach", "kale", "arugula", "rocket", "chard"], lines: [
                    .init(text: "Iron + vitamin C in greens = energy your body can actually use.", vibe: .smart),
                    .init(text: "Greens pack vitamin K to strengthen your bones.", vibe: .punchy),
                    .init(text: "Nitrate compounds support circulation throughout your whole body.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["sweet potato"], lines: [
                    .init(text: "Beta-carotene = glow from the inside out.", vibe: .punchy),
                    .init(text: "Complex carbs gently stabilize blood sugar.", vibe: .reassuring),
                    .init(text: "Sweet potatoes are comfort food that's actually good for you.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["potato"], lines: [
                    .init(text: "Potatoes replenish muscle glycogen fast.", vibe: .punchy),
                    .init(text: "More potassium than a banana... potatoes are not to be underestimated.", vibe: .funny),
                    .init(text: "Simple, bioavailable glucose your brain uses immediately.", vibe: .smart),
                ]),
                SpecificFood(keywords: ["tomato"], lines: [
                    .init(text: "Lycopene in tomatoes is one of the most powerful antioxidants going.", vibe: .smart),
                    .init(text: "Tomatoes support heart health through potassium & polyphenols.", vibe: .smart),
                    .init(text: "Gut-friendly acidity that can kickstart digestion.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["mushroom"], lines: [
                    .init(text: "Mushrooms are one of the only plant sources of vitamin D.", vibe: .smart),
                    .init(text: "Prebiotic fibre in mushrooms feeds the gut bacteria that shape your mood.", vibe: .smart),
                    .init(text: "Mushrooms are quietly doing more than almost any other vegetable.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["cucumber"], lines: [
                    .init(text: "Cucumbers are 96% water... hydration in its most enjoyable form.", vibe: .funny),
                    .init(text: "Silica in cucumber supports skin elasticity.", vibe: .smart),
                    .init(text: "Cooling, anti-inflammatory, & genuinely refreshing.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["beet", "beetroot"], lines: [
                    .init(text: "Nitrates in beetroot literally improve blood flow to your brain.", vibe: .smart),
                    .init(text: "Beetroot is one of the best natural performance boosters going.", vibe: .punchy),
                    .init(text: "Betalains support liver detoxification.", vibe: .smart),
                ]),
                SpecificFood(keywords: ["garlic"], lines: [
                    .init(text: "Allicin in garlic is one of the most studied immune compounds there is.", vibe: .smart),
                    .init(text: "Garlic actively lowers inflammation at a cellular level.", vibe: .smart),
                    .init(text: "Garlic's been used medicinally for thousands of years.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["pepper", "capsicum"], lines: [
                    .init(text: "Red peppers have more vitamin C than oranges, genuinely.", vibe: .funny),
                    .init(text: "Capsaicin triggers dopamine & serotonin at the same time.", vibe: .smart),
                    .init(text: "One of the most antioxidant-dense vegetables going.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["asparagus"], lines: [
                    .init(text: "Folate in asparagus supports serotonin production.", vibe: .smart),
                    .init(text: "A natural prebiotic... your gut bacteria love it.", vibe: .smart),
                    .init(text: "Asparagus is quietly doing its own detox work.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["pumpkin", "squash", "butternut"], lines: [
                    .init(text: "Beta-carotene converts to vitamin A for immune support.", vibe: .smart),
                    .init(text: "Comforting & nutritionally dense, pumpkin delivers on both.", vibe: .reassuring),
                    .init(text: "Pumpkin seeds are a complete source of protein & zinc.", vibe: .punchy),
                ]),
            ],
            fallback: [
                .init(text: "Vegetables are running detox, repair, & immune support simultaneously.", vibe: .smart),
                .init(text: "Fibre feeds the gut bacteria that shape your mood.", vibe: .smart),
                .init(text: "Whatever vegetable this is, your cells are using every bit of it.", vibe: .reassuring),
                .init(text: "Vegetables are basically your body's maintenance crew showing up.", vibe: .funny),
            ]
        ),

        // PROTEIN
        Category(
            keywords: [
                "protein", "chicken", "turkey", "poultry", "beef", "steak", "lamb",
                "pork", "ham", "bacon", "trout", "shrimp", "prawn", "crab",
                "lobster", "scallop", "seafood", "sushi", "sashimi", "maki",
                "onigiri", "egg", "omelette", "omelet", "scramble", "frittata", "tofu", "tempeh",
                "edamame", "bean", "lentil", "chickpea", "hummus", "nut", "almond",
                "walnut", "cashew", "pecan", "pistachio", "peanut", "peanut butter", "pb",
                "protein bar", "protein shake"
            ],
            specificFoods: [
                SpecificFood(keywords: ["egg", "omelette", "omelet", "scramble", "frittata"], lines: [
                    .init(text: "Choline in eggs is what your brain uses to actually think.", vibe: .smart),
                    .init(text: "Eggs were the original superfood before superfood was a word.", vibe: .funny),
                    .init(text: "Complete amino acid profile; eggs give your body everything it needs to rebuild.", vibe: .smart),
                    .init(text: "Eggs stabilize your blood sugar & your mood follows.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["chicken", "turkey", "poultry"], lines: [
                    .init(text: "Tryptophan in poultry is what your body converts to serotonin.", vibe: .smart),
                    .init(text: "Lean protein means muscle repair without the heaviness.", vibe: .reassuring),
                    .init(text: "Complete protein, delicious fuel, zero drama.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["salmon", "trout"], lines: [
                    .init(text: "Omega-3s in salmon literally build your brain cell membranes.", vibe: .smart),
                    .init(text: "EPA & DHA support neuron structure to improve mood.", vibe: .smart),
                    .init(text: "One of the most complete foods you can eat.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["beef", "steak", "lamb"], lines: [
                    .init(text: "B12 is what your brain & nervous system literally run on.", vibe: .smart),
                    .init(text: "Carnitine in red meat supports cellular energy production.", vibe: .smart),
                    .init(text: "Red meat fuels oxygen flow to every cell.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["peanut butter", "peanut", "pb"], lines: [
                    .init(text: "Your brain runs on fat (peanut butter delivers).", vibe: .smart),
                    .init(text: "Keeps energy even for hours.", vibe: .reassuring),
                    .init(text: "Top-tier fuel.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["almond", "walnut", "cashew", "pecan", "pistachio", "nut"], lines: [
                    .init(text: "Nuts are basically portable brain food.", vibe: .funny),
                    .init(text: "Healthy fats in nuts reduce brain fog.", vibe: .smart),
                    .init(text: "Magnesium in nuts supports sleep, mood, & stress regulation.", vibe: .smart),
                ]),
                SpecificFood(keywords: ["tofu", "tempeh"], lines: [
                    .init(text: "Complete plant protein, all 9 essential amino acids.", vibe: .smart),
                    .init(text: "Isoflavones in tofu support hormone balance.", vibe: .smart),
                    .init(text: "Fermented tempeh is one of the best plant-based proteins going.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["bean", "lentil", "chickpea", "hummus", "edamame"], lines: [
                    .init(text: "Plant protein that actually sustains.", vibe: .punchy),
                    .init(text: "Magnesium-rich fuel supports a calmer nervous system.", vibe: .smart),
                    .init(text: "Fibre + protein in one... legumes are genuinely efficient.", vibe: .smart),
                ]),
                SpecificFood(keywords: ["sushi", "sashimi", "maki", "onigiri"], lines: [
                    .init(text: "Glucose + omega-3s = cognitive sharpness.", vibe: .punchy),
                    .init(text: "EPA & DHA support neuron structure to improve your mood.", vibe: .smart),
                    .init(text: "More nutritionally complete than it gets credit for.", vibe: .reassuring),
                ]),
            ],
            fallback: [
                .init(text: "Protein is what your body uses to repair & rebuild everything.", vibe: .smart),
                .init(text: "Amino acids from protein are the literal building blocks of your brain.", vibe: .smart),
                .init(text: "Your muscles, hormones, & immune system all run on protein.", vibe: .punchy),
                .init(text: "Protein keeps blood sugar stable so your mood stays even.", vibe: .reassuring),
            ]
        ),

        // CARBS & GRAINS
        Category(
            keywords: [
                "carb", "grain", "bread", "sourdough", "baguette", "loaf", "toast",
                "pasta", "spaghetti", "penne", "fettuccine", "linguine", "mac and cheese",
                "mac & cheese", "rice", "oat", "oatmeal", "porridge", "cereal", "granola", "muesli",
                "pancake", "waffle", "wrap", "tortilla", "pita", "naan", "bagel",
                "muffin", "cracker", "pretzel", "rice cake", "chips", "crisps",
                "popcorn", "fries", "french fries", "potato chips", "ramen", "udon",
                "soba", "pho", "noodle", "couscous", "quinoa", "barley", "farro", "bulgur"
            ],
            specificFoods: [
                SpecificFood(keywords: ["oat", "porridge"], lines: [
                    .init(text: "The original slow-burn fuel.", vibe: .punchy),
                    .init(text: "Beta-glucan in oats is one of the most studied fibres for heart health.", vibe: .smart),
                    .init(text: "Unglamorous & incredibly effective.", vibe: .funny),
                    .init(text: "Oats keep you sharp when everything else is loud.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["bread", "sourdough", "baguette", "loaf"], lines: [
                    .init(text: "Bread gives your brain glucose to actually handle things.", vibe: .smart),
                    .init(text: "The most universally loved food for a reason (many reasons, actually).", vibe: .funny),
                    .init(text: "More energy, better mood, clearer head... bread really does it all.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["bagel"], lines: [
                    .init(text: "Carbs in bagels refuel glycogen stores faster than most breads.", vibe: .smart),
                    .init(text: "Bagels are a reliable energy source for a reason, they just work.", vibe: .reassuring),
                    .init(text: "Carbs + whatever you put on it = a genuinely complete meal.", vibe: .punchy),
                    .init(text: "Bagels are basically a delivery system for every other good food.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["pasta", "spaghetti", "penne", "fettuccine", "mac and cheese"], lines: [
                    .init(text: "Pasta has been carrying people through hard days since ancient Rome.", vibe: .funny),
                    .init(text: "Complex carbs = sustained energy.", vibe: .punchy),
                    .init(text: "Pasta gives back the energy the day took from you.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["rice"], lines: [
                    .init(text: "Gentle on your gut, generous with your energy.", vibe: .reassuring),
                    .init(text: "B vitamins in rice help your body turn food into actual energy.", vibe: .smart),
                    .init(text: "Rice hits your bloodstream fast... the perfect pick-me-up.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["pancake", "waffle"], lines: [
                    .init(text: "The best carbs to refuel depleted liver glycogen.", vibe: .smart),
                    .init(text: "Carbs that make you happy are doing more than you think.", vibe: .funny),
                    .init(text: "Restores baseline energy within minutes.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["fries", "french fries"], lines: [
                    .init(text: "Potassium in fries is what your muscles actually run on.", vibe: .smart),
                    .init(text: "Salty fries restore important electrolytes.", vibe: .reassuring),
                    .init(text: "Fries restore glycogen faster than almost anything.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["chips", "crisps", "popcorn"], lines: [
                    .init(text: "Carbs are your brain's fastest fuel source.", vibe: .smart),
                    .init(text: "Sodium helps your body retain water & stay hydrated.", vibe: .reassuring),
                    .init(text: "Sometimes quick carbs are exactly what your body is asking for.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["ramen", "udon", "soba", "pho", "noodle"], lines: [
                    .init(text: "Electrolytes from broth support nerve function.", vibe: .smart),
                    .init(text: "Carbs + warmth + broth is one of the most restorative combos going.", vibe: .reassuring),
                    .init(text: "Steam alone shifts you into parasympathetic mode.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["quinoa"], lines: [
                    .init(text: "One of the few plant foods with a complete amino acid profile.", vibe: .smart),
                    .init(text: "More protein than almost any other grain, quinoa earns its reputation.", vibe: .punchy),
                    .init(text: "Magnesium in quinoa supports sleep, mood, & stress regulation.", vibe: .smart),
                ]),
            ],
            fallback: [
                .init(text: "Carbs are your brain's preferred fuel, it literally runs on glucose.", vibe: .smart),
                .init(text: "Carbs aren't the enemy, they're actually the most efficient energy source going.", vibe: .funny),
                .init(text: "Grains have fuelled humans for centuries for good reason.", vibe: .reassuring),
                .init(text: "B vitamins in grains help your body convert food into usable energy.", vibe: .smart),
            ]
        ),

        // DAIRY
        Category(
            keywords: [
                "dairy", "milk", "cheese", "cheddar", "mozzarella", "parmesan", "brie",
                "feta", "gouda", "camembert", "ricotta", "cottage cheese", "cream cheese",
                "yogurt", "yoghurt", "greek yogurt", "kefir", "butter", "cream",
                "whipped cream", "ice cream", "gelato", "sorbet", "frozen yogurt", "froyo",
                "milkshake", "hot chocolate"
            ],
            specificFoods: [
                SpecificFood(keywords: ["yogurt", "yoghurt", "greek yogurt", "kefir"], lines: [
                    .init(text: "Protein + probiotics = the combo your body actually wants.", vibe: .punchy),
                    .init(text: "Live cultures support the gut-brain axis (your mood feels it).", vibe: .smart),
                    .init(text: "Yogurt is lowkey the MVP of the fridge.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["cheese", "cheddar", "mozzarella", "parmesan", "brie", "feta", "gouda", "ricotta", "cottage cheese"], lines: [
                    .init(text: "Tryptophan in cheese helps your body make serotonin.", vibe: .smart),
                    .init(text: "Cheese is just calcium & protein in their most enjoyable form.", vibe: .punchy),
                    .init(text: "Cheese turns any meal into something that satisfies.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["milk"], lines: [
                    .init(text: "Complete protein + calcium + B12, milk is really doing something.", vibe: .smart),
                    .init(text: "Tryptophan in milk supports serotonin & melatonin production.", vibe: .smart),
                    .init(text: "One of the most bioavailable sources of calcium going.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["ice cream", "gelato", "sorbet", "frozen yogurt", "froyo"], lines: [
                    .init(text: "The cold alone triggers a dopamine response... your brain loves it.", vibe: .smart),
                    .init(text: "Fat & sugar signal safety to your nervous system.", vibe: .funny),
                    .init(text: "Calcium in frozen desserts is what your bones run on.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["butter"], lines: [
                    .init(text: "Butter helps your body absorb vitamins, it's basically a delivery system.", vibe: .smart),
                    .init(text: "Your brain is 60% fat; butter is literally feeding it.", vibe: .funny),
                    .init(text: "Butter = real fat, real satiety, & real results.", vibe: .punchy),
                ]),
            ],
            fallback: [
                .init(text: "Calcium in dairy is what your bones & teeth run on.", vibe: .smart),
                .init(text: "Tryptophan in dairy is what your brain uses to make serotonin.", vibe: .smart),
                .init(text: "Complete protein & fat means your body stays satisfied longer.", vibe: .punchy),
                .init(text: "Whatever dairy this is, your skeletal system is saying thank you.", vibe: .funny),
            ]
        ),

        // SWEET TREATS
        Category(
            keywords: [
                "sweet", "dessert", "chocolate", "cocoa", "cacao", "candy", "lolly",
                "gummy", "cookie", "biscuit", "brownie", "cake", "cupcake",
                "muffin", "donut", "doughnut", "pastry", "croissant", "tart",
                "pudding", "custard", "mousse", "tiramisu", "cheesecake",
                "honey", "jam", "jelly", "marmalade", "syrup", "maple syrup",
                "caramel", "toffee", "fudge", "marshmallow", "wafer", "meringue",
                "crepe", "cinnamon"
            ],
            specificFoods: [
                SpecificFood(keywords: ["chocolate", "cocoa", "cacao"], lines: [
                    .init(text: "Theobromine in chocolate hits slower than caffeine & stays longer.", vibe: .smart),
                    .init(text: "Cocoa literally increases blood flow to your brain.", vibe: .smart),
                    .init(text: "Chocolate is basically legal serotonin.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["cookie", "biscuit"], lines: [
                    .init(text: "Sugar gives your brain an immediate glucose boost.", vibe: .smart),
                    .init(text: "Eating joyfully keeps cortisol low (yes, cookies count).", vibe: .funny),
                    .init(text: "Butter in cookies means fat-soluble vitamins absorbed.", vibe: .smart),
                ]),
                SpecificFood(keywords: ["cake", "cupcake"], lines: [
                    .init(text: "Cake raises serotonin & your whole mood shifts with it.", vibe: .smart),
                    .init(text: "Vanilla has a measurably calming effect on your brain.", vibe: .funny),
                    .init(text: "Baked goods warm your nervous system from the inside out.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["honey"], lines: [
                    .init(text: "Natural fructose helps your liver process more efficiently.", vibe: .smart),
                    .init(text: "Packed with prebiotics that support your mood.", vibe: .smart),
                    .init(text: "Used medicinally for centuries, honey has always been working hard.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["pastry", "croissant", "donut", "doughnut"], lines: [
                    .init(text: "Butter improves the absorption of key nutrients.", vibe: .smart),
                    .init(text: "Baked goods support serotonin production through carbohydrate intake.", vibe: .punchy),
                    .init(text: "Warm baked goods stimulate parasympathetic relaxation.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["syrup", "maple syrup", "jam", "jelly", "marmalade", "preserve", "compote"], lines: [
                    .init(text: "Natural sugars hit your bloodstream fast, exactly what a low-energy moment needs.", vibe: .smart),
                    .init(text: "Syrup has more antioxidants than you'd ever expect from something that tasty.", vibe: .funny),
                    .init(text: "Fruit-based spreads carry polyphenols from the original fruit.", vibe: .reassuring),
                    .init(text: "Quick glucose for your brain, delivered deliciously.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["cinnamon"], lines: [
                    .init(text: "Cinnamon is one of the most antioxidant-dense spices on the planet.", vibe: .punchy),
                    .init(text: "Used medicinally for thousands of years & the science is finally catching up.", vibe: .funny),
                    .init(text: "Anti-inflammatory compounds in cinnamon are always working quietly.", vibe: .reassuring),
                ]),
            ],
            fallback: [
                .init(text: "Eating joyfully keeps cortisol low (that's science).", vibe: .smart),
                .init(text: "Sweet tastes activate dopamine pathways... your brain genuinely needs that.", vibe: .smart),
                .init(text: "Joy is a legitimate nutritional benefit.", vibe: .funny),
                .init(text: "Eating something you love reduces stress hormones (just saying).", vibe: .reassuring),
            ]
        ),
        
        // MISCELLANEOUS
        Category(
            keywords: [
                "coffee", "espresso", "americano", "latte", "cappuccino", "flat white", "cold brew",
                "matcha", "tea", "green tea", "black tea", "herbal tea", "chai",
                "smoothie", "juice", "orange juice", "apple juice", "green juice",
                "soup", "stew", "broth", "bisque", "chowder",
                "pizza", "burger", "cheeseburger", "hot dog", "sandwich", "sub", "wrap", "panini",
                "salad", "caesar", "coleslaw",
                "sausage", "mince", "ground beef", "chorizo", "salami", "pepperoni",
                "tuna", "sardine", "cod", "fish", "halibut", "tilapia", "anchovy",
                "olive oil", "seed", "chia", "flax", "sunflower seed", "pumpkin seed", "sesame",
                "granola", "muesli", "cereal"
            ],
            specificFoods: [
                SpecificFood(keywords: ["coffee", "espresso", "americano", "cold brew"], lines: [
                    .init(text: "Caffeine in coffee blocks adenosine (the compound that makes you feel tired).", vibe: .smart),
                    .init(text: "Coffee increases dopamine signalling... it's a mood lifter backed by science.", vibe: .smart),
                    .init(text: "The antioxidant count in coffee is higher than almost any other drink.", vibe: .punchy),
                ]),
                SpecificFood(keywords: ["matcha"], lines: [
                    .init(text: "L-theanine in matcha gives calm focus without the caffeine crash.", vibe: .smart),
                    .init(text: "Matcha has 137x more antioxidants than regular green tea.", vibe: .punchy),
                    .init(text: "The smoothest energy you can drink.", vibe: .reassuring),
                    .init(text: "Matcha is basically focus in a cup.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["tea", "green tea", "black tea", "herbal tea", "chai"], lines: [
                    .init(text: "L-theanine in tea promotes calm alertness without the jitters.", vibe: .smart),
                    .init(text: "One of the most universally soothing things you can do for your body.", vibe: .reassuring),
                    .init(text: "Humans have been drinking tea for thousands of years (for a reason).", vibe: .funny),
                ]),
                SpecificFood(keywords: ["smoothie", "juice", "orange juice", "apple juice", "green juice"], lines: [
                    .init(text: "Liquid nutrition hits your bloodstream faster than almost anything solid.", vibe: .smart),
                    .init(text: "A concentrated hit of vitamins your body can use immediately.", vibe: .punchy),
                    .init(text: "Hydration + nutrients in one go, smoothies are putting in the work.", vibe: .reassuring),
                    .init(text: "Your immune system just got a serious delivery.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["soup", "stew", "broth", "bisque", "chowder"], lines: [
                    .init(text: "Electrolytes from broth support nerve & muscle function.", vibe: .smart),
                    .init(text: "Warm liquid signals safety to your nervous system.", vibe: .reassuring),
                    .init(text: "Collagen from bone broth is what your joints & skin run on.", vibe: .smart),
                    .init(text: "Soup is basically a hug that your body absorbs.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["pizza"], lines: [
                    .init(text: "Carbs + protein + fat = one of the most complete macronutrient combos going.", vibe: .smart),
                    .init(text: "Lycopene in tomato sauce is more bioavailable cooked than raw.", vibe: .smart),
                    .init(text: "Pizza has been feeding people joyfully for centuries.", vibe: .funny),
                    .init(text: "Cheese + dough + sauce is satisfying your body on multiple levels.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["burger", "cheeseburger"], lines: [
                    .init(text: "Protein + fat + carbs... burgers hit every macronutrient.", vibe: .smart),
                    .init(text: "Iron from beef fuels oxygen transport to every cell in your body.", vibe: .smart),
                    .init(text: "A burger is basically a complete meal in one hand.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["sandwich", "sub", "wrap", "panini"], lines: [
                    .init(text: "Carbs + protein in one is exactly the combo your brain & muscles want.", vibe: .smart),
                    .init(text: "One of the most practical, complete meals going.", vibe: .punchy),
                    .init(text: "Bread gives your brain glucose, filling gives your body everything else.", vibe: .reassuring),
                    .init(text: "Portable, balanced, underrated.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["salad", "caesar", "coleslaw"], lines: [
                    .init(text: "Raw vegetables deliver enzymes that support digestion.", vibe: .smart),
                    .init(text: "Fibre in salad feeds gut bacteria that directly influence your mood.", vibe: .smart),
                    .init(text: "Micronutrient density in a good salad is genuinely hard to beat.", vibe: .punchy),
                    .init(text: "Your gut bacteria just got a really good day.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["sausage", "chorizo", "salami", "pepperoni", "mince", "ground beef"], lines: [
                    .init(text: "B12 from red meat is what your brain & nervous system run on.", vibe: .smart),
                    .init(text: "Protein + fat = satiety that actually lasts.", vibe: .punchy),
                    .init(text: "Iron in red meat fuels oxygen flow to every cell.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["tuna", "sardine", "cod", "fish", "halibut", "tilapia", "anchovy"], lines: [
                    .init(text: "Omega-3s in fish literally build your brain cell membranes.", vibe: .smart),
                    .init(text: "EPA & DHA in fish support mood regulation at a neurological level.", vibe: .smart),
                    .init(text: "Fish is one of the best sources of complete protein going.", vibe: .reassuring),
                ]),
                SpecificFood(keywords: ["olive oil"], lines: [
                    .init(text: "Oleocanthal in olive oil has the same anti-inflammatory mechanism as ibuprofen.", vibe: .smart),
                    .init(text: "Olive oil makes every other food more nutritious; fat = better absorption.", vibe: .punchy),
                    .init(text: "Liquid gold that's been supporting human health for thousands of years.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["chia", "flax", "seed", "sunflower seed", "pumpkin seed", "sesame"], lines: [
                    .init(text: "Seeds are one of the most nutrient-dense foods per gram.", vibe: .smart),
                    .init(text: "Omega-3s in chia & flax support brain function & reduce inflammation.", vibe: .smart),
                    .init(text: "Zinc in pumpkin seeds supports immune function & hormone balance.", vibe: .punchy),
                    .init(text: "Tiny but doing an unreasonable amount of work.", vibe: .funny),
                ]),
                SpecificFood(keywords: ["granola", "muesli", "cereal"], lines: [
                    .init(text: "Whole grains deliver B vitamins that convert food into actual energy.", vibe: .smart),
                    .init(text: "Oats & grains provide slow-release glucose your brain runs on all morning.", vibe: .reassuring),
                    .init(text: "Fibre in granola feeds the gut bacteria that shape your mood.", vibe: .smart),
                    .init(text: "Granola is genuinely one of the easiest ways to start the day well.", vibe: .funny),
                ]),
            ],
            fallback: [
                .init(text: "Your body knows what to do with food, trust it.", vibe: .reassuring),
                .init(text: "Eating was the right call.", vibe: .funny),
                .init(text: "Nourishment comes in more forms than people give it credit for.", vibe: .smart),
            ]
        ),
    ]
}
