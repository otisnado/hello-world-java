package com.otisnado.helloWorld;

import java.net.InetAddress;
import java.net.UnknownHostException;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloWorldController {
	@GetMapping("/")
    public String hello(@RequestParam(value = "name", defaultValue = "World") String name) throws UnknownHostException {
      return String.format("Hello %s, you are in %s!", name, InetAddress.getLocalHost().getHostName());
	}
}
