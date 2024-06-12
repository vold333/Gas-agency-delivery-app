package com.example.gas.controller;

import com.example.gas.model.OrderForm;
import com.example.gas.repository.DriverRepository;
import com.example.gas.repository.OrderFormRepository;
import com.example.gas.model.Driver;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/order")
@CrossOrigin
public class OrderFormController {

    @Value("${file.storage.location}")
    private String uploadDir;

    @Autowired
    private OrderFormRepository orderFormRepository;

    @Autowired
    private DriverRepository driverRepository;

    @PostMapping("/create")
    public OrderForm createOrder(@RequestPart("orderForm") String orderFormJson,
                                 @RequestPart(value = "document", required = false) MultipartFile file) throws IOException {
        // Convert JSON string to OrderForm object
        ObjectMapper objectMapper = new ObjectMapper();
        OrderForm orderForm = objectMapper.readValue(orderFormJson, OrderForm.class);

        // Check if the totalPrice is present in the orderForm JSON
        if (!orderFormJson.contains("totalPrice")) {
            throw new IllegalArgumentException("totalPrice is required in orderForm");
        }

        // Handle file upload
        if (file != null && !file.isEmpty()) {
            String fileName = file.getOriginalFilename();
            Path path = Paths.get(uploadDir + File.separator + fileName);
            Files.createDirectories(path.getParent());
            Files.write(path, file.getBytes());

            // Set the document path in the OrderForm
            orderForm.setDocument(path.toString());
        }

        // Check if the driver exists in the database
        Long driverId = orderForm.getDriver().getId();
        Optional<Driver> driverOptional = driverRepository.findById(driverId);
        if (driverOptional.isPresent()) {
            Driver driver = driverOptional.get();
            orderForm.setDriver(driver);
            return orderFormRepository.save(orderForm);
        } else {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Driver not found with ID: " + driverId);
        }
    }

    @GetMapping("/get/{driverId}")
    public List<OrderForm> getOrdersByDriverId(@PathVariable Long driverId) {
        // Find orders by driver ID
        List<OrderForm> orders = orderFormRepository.findByDriverId(driverId);
        if (orders.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No orders found for Driver ID: " + driverId);
        }
        return orders;
    }
}
