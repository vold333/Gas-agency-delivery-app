package com.example.gas.controller;

import com.example.gas.model.Driver;
import com.example.gas.service.DriverService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/drivers")
public class DriverController {

    @Autowired
    private DriverService driverService;

    @PostMapping("/register")
    public Driver registerDriver(@RequestBody Driver driver) {
        return driverService.saveDriver(driver);
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginDriver(@RequestBody Driver driver) {
        Optional<Driver> foundDriver = driverService.findByEmail(driver.getEmail());
        if (foundDriver.isPresent() && foundDriver.get().getPassword().equals(driver.getPassword())) {
            Map<String, Object> response = new HashMap<>(); // Modified to use Object type for ID
            response.put("id", foundDriver.get().getId()); // Include ID in the response map
            response.put("name", foundDriver.get().getName());
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid email or password");
        }
    }
}

