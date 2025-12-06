package com.simstruct.backend.security;

import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.Optional;

/**
 * JWT Authentication Filter - checks JWT token on each request
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                    HttpServletResponse response, 
                                    FilterChain filterChain) throws ServletException, IOException {
        
        // Get token from header
        String authHeader = request.getHeader("Authorization");
        
        // Check if token exists and starts with "Bearer "
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            
            System.out.println("JWT Filter: Token found in request");
            
            // Validate token
            if (jwtTokenProvider.validateToken(token)) {
                // Get user ID from token
                String userId = jwtTokenProvider.getUserIdFromToken(token);
                System.out.println("JWT Filter: User ID from token: " + userId);
                
                // Find user in database
                Optional<User> userOpt = userRepository.findById(userId);
                
                if (userOpt.isPresent()) {
                    User user = userOpt.get();
                    System.out.println("JWT Filter: User found: " + user.getEmail());
                    
                    // Create authentication token
                    UsernamePasswordAuthenticationToken authentication = 
                        new UsernamePasswordAuthenticationToken(
                            user, 
                            null, 
                            Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()))
                        );
                    
                    // Set authentication in context
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                    System.out.println("JWT Filter: Authentication set for user: " + user.getEmail());
                }
            }
        }
        
        // Continue with filter chain
        filterChain.doFilter(request, response);
    }
}
