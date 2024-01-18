package imt.projetrentree.projet;

import imt.projetrentree.projet.dto.user.UserCreationDTO;
import imt.projetrentree.projet.models.Dish;
import imt.projetrentree.projet.models.User;
import imt.projetrentree.projet.models.enums.DishDiet;
import imt.projetrentree.projet.models.enums.DishTag;
import imt.projetrentree.projet.repositories.DishRepository;
import imt.projetrentree.projet.repositories.UserRepository;
import imt.projetrentree.projet.services.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.List;
import java.util.Optional;

import static org.mockito.Mockito.*;

public class ProjetApplicationTest {

    @Mock
    private DishRepository dishRepository;

    @Mock
    private UserService userService;

    @Mock
    private UserRepository userRepository;

    private ProjetApplication projetApplication;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.initMocks(this);
        projetApplication = new ProjetApplication();
        projetApplication.dishRepository = dishRepository;
        projetApplication.userService = userService;
        projetApplication.userRepository = userRepository;
    }

    @Test
    void testSaveDishIfNotExists_DishExists() {
        // Mock the behavior of dishRepository
        when(dishRepository.findByName(anyString())).thenReturn(Optional.of(new Dish()));

        // Call the method to be tested
        projetApplication.saveDishIfNotExists("Test Dish", "image", "description", "allergens", 10.0, List.of(DishTag.MEAT), DishDiet.NORMAL);

        // Verify that dishRepository.save() is not called because the dish already exists
        verify(dishRepository, never()).save(any());
    }

    @Test
    void testSaveDishIfNotExists_DishDoesNotExist() {
        // Mock the behavior of dishRepository
        when(dishRepository.findByName(anyString())).thenReturn(Optional.empty());

        // Call the method to be tested
        projetApplication.saveDishIfNotExists("Test Dish", "image", "description", "allergens", 10.0, List.of(DishTag.MEAT), DishDiet.NORMAL);

        // Verify that dishRepository.save() is called to save the new dish
        verify(dishRepository, times(1)).save(any());
    }

    @Test
    void testSaveUserIfNotExists_UserExists() {
        // Mock the behavior of userRepository
        when(userRepository.existsByEmail(anyString())).thenReturn(true);

        // Call the method to be tested
        projetApplication.saveUserIfNotExists("user@user.com", "password", "First", "Last", "Address");

        // Verify that userService.register() is not called because the user already exists
        verify(userService, never()).register(any(), anyDouble());
    }

    @Test
    void testSaveUserIfNotExists_UserDoesNotExist() {
        // Mock the behavior of userRepository
        when(userRepository.existsByEmail(anyString())).thenReturn(false);

        // Call the method to be tested
        projetApplication.saveUserIfNotExists("user@user.com", "password", "First", "Last", "Address");

        // Verify that userService.register() is called to register the new user
        verify(userService, times(1)).register(any(UserCreationDTO.class), anyDouble());
    }
}
