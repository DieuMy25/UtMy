package utmy.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HomeController {

	@RequestMapping("home")
	public String home(Model model) {
		model.addAttribute("message", "Nguyen Thi Dieu My - Welcome to Spring MVC");
		return "index";
	}

	@RequestMapping("index")
	public String index(Model model) {
		model.addAttribute("message", "Welcome to Spring MVC");
		return "index";
	}

}