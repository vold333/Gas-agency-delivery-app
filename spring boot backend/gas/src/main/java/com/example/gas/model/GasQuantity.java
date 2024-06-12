package com.example.gas.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class GasQuantity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long driverId;
    private Integer lpgQuantity;  // Changed to Integer to handle null values
    private double lpgPrice;
    private Integer butaneQuantity;  // Changed to Integer to handle null values
    private double butanePrice;
    private Integer propaneQuantity;  // Changed to Integer to handle null values
    private double propanePrice;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }

    public Integer getLpgQuantity() {
        return lpgQuantity;
    }

    public void setLpgQuantity(Integer lpgQuantity) {
        this.lpgQuantity = lpgQuantity;
    }

    public double getLpgPrice() {
        return lpgPrice;
    }

    public void setLpgPrice(double lpgPrice) {
        this.lpgPrice = lpgPrice;
    }

    public Integer getButaneQuantity() {
        return butaneQuantity;
    }

    public void setButaneQuantity(Integer butaneQuantity) {
        this.butaneQuantity = butaneQuantity;
    }

    public double getButanePrice() {
        return butanePrice;
    }

    public void setButanePrice(double butanePrice) {
        this.butanePrice = butanePrice;
    }

    public Integer getPropaneQuantity() {
        return propaneQuantity;
    }

    public void setPropaneQuantity(Integer propaneQuantity) {
        this.propaneQuantity = propaneQuantity;
    }

    public double getPropanePrice() {
        return propanePrice;
    }

    public void setPropanePrice(double propanePrice) {
        this.propanePrice = propanePrice;
    }
}

