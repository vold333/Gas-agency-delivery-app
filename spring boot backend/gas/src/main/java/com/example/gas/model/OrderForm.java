package com.example.gas.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "order_form")
public class OrderForm {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String contactNumber;
    private String consumerNumber;
    private String address;
    private String email;
    private String document;
    private int lpgQuantity;
    private int butaneQuantity;
    private int propaneQuantity;
    private double totalPrice;

    @ManyToOne
    @JoinColumn(name = "driver_id")
    private Driver driver;

    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // Getters and setters...

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getContactNumber() {
        return contactNumber;
    }

    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }

    public String getConsumerNumber() {
        return consumerNumber;
    }

    public void setConsumerNumber(String consumerNumber) {
        this.consumerNumber = consumerNumber;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getDocument() {
        return document;
    }

    public void setDocument(String document) {
        this.document = document;
    }

    public int getLpgQuantity() {
        return lpgQuantity;
    }

    public void setLpgQuantity(int lpgQuantity) {
        this.lpgQuantity = lpgQuantity;
    }

    public int getButaneQuantity() {
        return butaneQuantity;
    }

    public void setButaneQuantity(int butaneQuantity) {
        this.butaneQuantity = butaneQuantity;
    }

    public int getPropaneQuantity() {
        return propaneQuantity;
    }

    public void setPropaneQuantity(int propaneQuantity) {
        this.propaneQuantity = propaneQuantity;
    }

    public Driver getDriver() {
        return driver;
    }

    public void setDriver(Driver driver) {
        this.driver = driver;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }
}

