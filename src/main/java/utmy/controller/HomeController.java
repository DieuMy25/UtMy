package utmy.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("title", "Nguyen Thi Dieu My - Welcome to Spring MVC");
        return "home/index"; // Thymeleaf sẽ tìm templates/home/index.html
    }
}
