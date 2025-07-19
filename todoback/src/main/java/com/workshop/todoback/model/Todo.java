package com.workshop.todoback.model; // IMPORTANT: Updated package name

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.Data;

@Data
@Entity
public class Todo { // Renamed from TodoItem

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String description;
    private boolean completed;

    public Todo() {
    }

    public Todo(String description, boolean completed) {
        this.description = description;
        this.completed = completed;
    }
}