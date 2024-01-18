package imt.projetrentree.projet;

import imt.projetrentree.projet.dto.user.UserCreationDTO;
import imt.projetrentree.projet.models.Dish;
import imt.projetrentree.projet.models.User;
import imt.projetrentree.projet.models.enums.DishDiet;
import imt.projetrentree.projet.models.enums.DishTag;
import imt.projetrentree.projet.repositories.DishRepository;
import imt.projetrentree.projet.repositories.UserRepository;
import imt.projetrentree.projet.services.UserService;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

import java.util.List;

@SpringBootApplication
@EnableAsync
public class ProjetApplication {
    @Autowired
    DishRepository dishRepository;

    @Autowired
    UserService userService;

    @Autowired
    UserRepository userRepository;

    public static final String APP_NAME = "DeliveCROUS";

    public static void main(String[] args) {
        SpringApplication.run(ProjetApplication.class, args);
    }

    @PostConstruct
    public void init() {
        saveDishIfNotExists("Spaghetti Carbonara", "https://img.cuisineaz.com/660x660/2023/04/11/i192604-pates-a-la-carbonara.jpg", "Plat de pâtes italien classique avec des œufs, du fromage, de la pancetta et du poivre noir.", "Contient: œufs, produits laitiers, porc", 12.99, List.of(DishTag.MEAT, DishTag.DAIRY), DishDiet.NORMAL);
        saveDishIfNotExists("Salmon grillé", "https://thekitchengirl.com/wp-content/uploads/Grilled-Salmon-a_19-1.jpg", "Filet de saumon frais assaisonné et grillé à la perfection.", "Contient: poisson", 18.50, List.of(DishTag.FISH, DishTag.HEALTHY), DishDiet.NORMAL);
        saveDishIfNotExists("Pizza Margherita", "https://fr.ooni.com/cdn/shop/articles/Margherita-9920.jpg?crop=center&height=800&v=1644590066&width=800", "Pizza traditionnelle garnie de tomates fraîches, de mozzarella, de basilic et d'huile d'olive.", "Contient: produits laitiers", 14.75, List.of(DishTag.VEGETABLE, DishTag.DAIRY), DishDiet.NORMAL);
        saveDishIfNotExists("Poulet sauté", "https://www.allrecipes.com/thmb/xvlRRhK5ldXuGcXad8XDM5tTAfE=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/223382_chicken-stir-fry_Rita-1x1-1-b6b835ccfc714bb6a8391a7c47a06a84.jpg", "Poulet tranché et légumes mélangés sautés dans une sauce savoureuse.", "Contient: volaille", 10.95, List.of(DishTag.MEAT, DishTag.VEGETABLE, DishTag.POULTRY), DishDiet.NORMAL);
        saveDishIfNotExists("Salade César", "https://www.allrecipes.com/thmb/mXZ0Tulwn3x9_YB_ZbkiTveDYFE=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/229063-Classic-Restaurant-Caesar-Salad-ddmfs-4x3-231-89bafa5e54dd4a8c933cf2a5f9f12a6f.jpg", "Laitue romaine croustillante, croûtons, fromage parmesan et vinaigrette César.", "Contient: produits laitiers", 8.25, List.of(DishTag.VEGETABLE, DishTag.DAIRY, DishTag.HEALTHY), DishDiet.NORMAL);
        saveDishIfNotExists("Tacos au boeuf", "https://www.saltandlavender.com/wp-content/uploads/2020/11/ground-beef-tacos-recipe-1.jpg", "Tortillas de maïs souples garnies de bœuf assaisonné, laitue, fromage et salsa.", "Contient: bœuf, produits laitiers", 9.50, List.of(DishTag.MEAT, DishTag.DAIRY, DishTag.VEGETABLE), DishDiet.NORMAL);
        saveDishIfNotExists("Risotto aux champignons", "https://cdn.loveandlemons.com/wp-content/uploads/2023/01/mushroom-risotto.jpg", "Risotto crémeux cuit avec du riz Arborio et un mélange de champignons.", "Contient: produits laitiers", 11.75, List.of(DishTag.VEGETABLE, DishTag.DAIRY), DishDiet.NORMAL);
        saveDishIfNotExists("Curry de légumes", "https://www.acouplecooks.com/wp-content/uploads/2020/02/Vegetable-Curry-001.jpg", "Légumes assortis mijotés dans une sauce curry parfumée, servis avec du riz.", "Contient: aucun", 13.25, List.of(DishTag.VEGETABLE, DishTag.VEGAN), DishDiet.VEGETARIAN);
        saveDishIfNotExists("BBQ Ribs", "https://tequilasrestaurant.co.uk/wp-content/uploads/2023/07/sauced-pork-ribs-on-a-baoking-sheet.jpg", "Côtes de porc cuites lentement nappées de sauce barbecue fumée.", "Contient: porc", 16.99, List.of(DishTag.MEAT), DishDiet.NORMAL);
        saveDishIfNotExists("Fondant au chocolat", "https://gimmedelicious.com/wp-content/uploads/2020/01/Chocolate-Molten-Lava-Cakes-10.jpg", "Gâteau au chocolat chaud avec un centre fondant, surmonté de glace à la vanille.", "Contient: produits laitiers, œufs", 7.50, List.of(DishTag.DESSERT, DishTag.DAIRY), DishDiet.NORMAL);
        saveDishIfNotExists("Burger Vegan", "https://img.cuisineaz.com/660x660/2016/06/07/i95896-burger-veggie-au-steak-de-pois-chiches.jpg", "Burger végétalien avec fromage végétalien, bacon végétalien, mayonnaise végétalienne, salade végétalienne, tomate végétalienne, oignon végétalien, ketchup végétalien, moutarde végétalienne, cornichons végétaliens, pain végétalien.", "Contient: aucun", 15.99, List.of(DishTag.VEGETABLE, DishTag.VEGAN), DishDiet.VEGAN);

        saveUserIfNotExists("user@user.com", "user", "Prénom", "Nom", "Adresse");
        saveAdmin();
    }

    void saveUserIfNotExists(String email, String password, String firstname, String lastname, String address) {
        if (!userRepository.existsByEmail(email)) {
            UserCreationDTO user = UserCreationDTO.builder()
                    .email(email)
                    .password(password)
                    .firstname(firstname)
                    .lastname(lastname)
                    .address(address)
                    .build();
            userService.register(user, 10000);
        }
    }

    private void saveAdmin() {
        if (!userRepository.existsByEmail("admin@admin.com")) {
            User admin = User.builder()
                    .email("admin@admin.com")
                    .password("admin")
                    .firstname("Prénom Admin")
                    .lastname("Nom Admin")
                    .balance(1000000.0)
                    .address("Adresse Admin")
                    .isAdmin(true)
                    .build();
            userRepository.save(admin);
        }
    }

    void saveDishIfNotExists(String name, String image, String description, String alergens, double price, List<DishTag> dishTags, DishDiet dishDiet) {
        if (dishRepository.findByName(name).isEmpty()) {
            Dish dish = Dish.builder()
                    .name(name)
                    .image(image)
                    .description(description)
                    .alergens(alergens)
                    .price(price)
                    .tags(dishTags)
                    .diet(dishDiet)
                    .build();
            dishRepository.save(dish);
        }
    }

}
