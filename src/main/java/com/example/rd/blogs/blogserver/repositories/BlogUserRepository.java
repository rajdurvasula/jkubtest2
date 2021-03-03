package com.example.rd.blogs.blogserver.repositories;

import com.example.rd.blogs.blogserver.models.BlogUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository("blogUserRepository")
public interface BlogUserRepository extends JpaRepository<BlogUser, Long> {
    BlogUser findByEmailId(String emailId);
}