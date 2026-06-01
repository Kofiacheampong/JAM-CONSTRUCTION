// JAM Construction Website JavaScript
// Lead Generation and Form Handling

(function() {
    'use strict';
    
    // DOM Content Loaded
    document.addEventListener('DOMContentLoaded', function() {
        initializeWebsite();
    });
    
    function initializeWebsite() {
        setupMobileMenu();
        setupSmoothScrolling();
        setupFormValidation();
        setupIntersectionObserver();
        setupContactTracking();
        setupScrollToTopButton();
        setupNavbarScrollEffect();
    }
    
    // Mobile Menu Toggle
    function setupMobileMenu() {
        const mobileToggle = document.querySelector('.mobile-menu-toggle');
        const navMenu = document.querySelector('.nav-menu');
        
        if (mobileToggle && navMenu) {
            mobileToggle.addEventListener('click', function() {
                const isOpen = navMenu.classList.toggle('active');
                mobileToggle.classList.toggle('active');
                mobileToggle.setAttribute('aria-expanded', isOpen);
            });

            const navLinks = document.querySelectorAll('.nav-menu a');
            navLinks.forEach(link => {
                link.addEventListener('click', function() {
                    navMenu.classList.remove('active');
                    mobileToggle.classList.remove('active');
                    mobileToggle.setAttribute('aria-expanded', 'false');
                });
            });
        }
    }
    
    // Smooth Scrolling for Navigation Links
    function setupSmoothScrolling() {
        const navLinks = document.querySelectorAll('a[href^="#"]');
        
        navLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                
                const targetId = this.getAttribute('href').substring(1);
                const targetElement = document.getElementById(targetId);
                
                if (targetElement) {
                    const headerOffset = 80;
                    const elementPosition = targetElement.getBoundingClientRect().top;
                    const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
                    
                    window.scrollTo({
                        top: offsetPosition,
                        behavior: 'smooth'
                    });
                }
            });
        });
    }
    
    // Form Validation and Submission
    function setupFormValidation() {
        const forms = document.querySelectorAll('form');
        
        forms.forEach(form => {
            form.addEventListener('submit', handleFormSubmit);
            
            // Real-time validation
            const inputs = form.querySelectorAll('input, select, textarea');
            inputs.forEach(input => {
                input.addEventListener('blur', () => validateField(input));
                input.addEventListener('input', () => clearFieldError(input));
            });
        });
    }
    
    function handleFormSubmit(e) {
        const form = e.target;
        const formData = new FormData(form);

        // Validate all fields
        let isValid = true;
        const requiredFields = form.querySelectorAll('[required]');

        requiredFields.forEach(field => {
            if (!validateField(field)) {
                isValid = false;
            }
        });

        // Prevent submission if validation fails
        if (!isValid) {
            e.preventDefault();
            return false;
        }

        // Populate hidden tracking fields before submission
        populateTrackingFields(form);

        // Show loading state
        const submitButton = form.querySelector('button[type="submit"]');
        const originalText = submitButton.textContent;
        submitButton.textContent = 'Sending...';
        submitButton.disabled = true;

        handleFormSubmission(formData);

        // Track conversion
        trackLeadGeneration(form.id, formData);

        // Allow form to submit naturally to Formspree
        // Formspree will handle the redirect to thank-you page
        return true;
    }

    function populateTrackingFields(form) {
        // Populate lead source from URL parameters or referrer
        const urlParams = new URLSearchParams(window.location.search);
        const leadSourceField = form.querySelector('#lead-source');
        const leadMediumField = form.querySelector('#lead-medium');
        const pageUrlField = form.querySelector('#page-url');

        if (leadSourceField) {
            leadSourceField.value = urlParams.get('utm_source') || document.referrer || 'direct';
        }
        if (leadMediumField) {
            leadMediumField.value = urlParams.get('utm_medium') || 'organic';
        }
        if (pageUrlField) {
            pageUrlField.value = window.location.href;
        }
    }
    
    function validateField(field) {
        const fieldGroup = field.closest('.form-group');
        const errorMessage = fieldGroup.querySelector('.error-message');
        
        let isValid = true;
        let message = '';
        
        // Required field validation
        if (field.hasAttribute('required') && !field.value.trim()) {
            isValid = false;
            message = 'This field is required.';
        }
        
        // Email validation
        if (field.type === 'email' && field.value.trim()) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(field.value)) {
                isValid = false;
                message = 'Please enter a valid email address.';
            }
        }
        
        // Phone validation
        if (field.type === 'tel' && field.value.trim()) {
            const phoneRegex = /^[\+]?[1-9][\d]{0,15}$/;
            const cleanPhone = field.value.replace(/\D/g, '');
            if (cleanPhone.length < 10) {
                isValid = false;
                message = 'Please enter a valid phone number.';
            }
        }
        
        // Update field appearance and error message
        if (isValid) {
            fieldGroup.classList.remove('error');
            fieldGroup.classList.add('success');
            errorMessage.textContent = '';
        } else {
            fieldGroup.classList.remove('success');
            fieldGroup.classList.add('error');
            errorMessage.textContent = message;
        }
        
        return isValid;
    }
    
    function clearFieldError(field) {
        const fieldGroup = field.closest('.form-group');
        if (field.value.trim()) {
            fieldGroup.classList.remove('error');
        }
    }
    
    function handleFormSubmission(formData) {
        const leadData = {
            type: 'estimate_request',
            name: formData.get('name'),
            email: formData.get('email'),
            phone: formData.get('phone'),
            projectType: formData.get('project_type'),
            budget: formData.get('budget_range'),
            message: formData.get('message'),
            timestamp: new Date().toISOString(),
            source: 'website',
            page: window.location.pathname
        };

        storeLeadData(leadData);
    }
    
    function storeLeadData(leadData) {
        // Store in localStorage for now (replace with actual database)
        let leads = JSON.parse(localStorage.getItem('jam_leads') || '[]');
        leads.push(leadData);
        localStorage.setItem('jam_leads', JSON.stringify(leads));
        
        // In production, send to your CRM/database:
        // fetch('/api/leads', {
        //     method: 'POST',
        //     headers: { 'Content-Type': 'application/json' },
        //     body: JSON.stringify(leadData)
        // });
    }
    
    function trackLeadGeneration(formId, formData) {
        if (typeof gtag !== 'undefined') {
            gtag('event', 'lead_generation', {
                'form_id': formId,
                'project_type': formData.get('project_type') || 'unknown',
                'lead_value': calculateLeadValue(formData.get('budget_range'))
            });
        }

        if (typeof fbq !== 'undefined') {
            fbq('track', 'Lead', {
                content_name: 'Estimate Request',
                value: calculateLeadValue(formData.get('budget_range')),
                currency: 'USD'
            });
        }
    }
    
    function calculateLeadValue(budget) {
        const budgetValues = {
            'under-50k': 50000,
            '50k-100k': 75000,
            '100k-250k': 175000,
            '250k-500k': 375000,
            '500k-1m': 750000,
            'over-1m': 1000000
        };
        return budgetValues[budget] || 50000;
    }
    
    // Contact Tracking (Phone, Email clicks)
    function setupContactTracking() {
        // Pre-populate tracking fields for all forms on page load
        const forms = document.querySelectorAll('form');
        forms.forEach(form => {
            populateTrackingFields(form);
        });

        // Track phone number clicks
        const phoneLinks = document.querySelectorAll('a[href^="tel:"]');
        phoneLinks.forEach(link => {
            link.addEventListener('click', function() {
                if (typeof gtag !== 'undefined') {
                    gtag('event', 'phone_click', {
                        'phone_number': this.getAttribute('href').replace('tel:', '')
                    });
                }
            });
        });

        // Track email clicks
        const emailLinks = document.querySelectorAll('a[href^="mailto:"]');
        emailLinks.forEach(link => {
            link.addEventListener('click', function() {
                if (typeof gtag !== 'undefined') {
                    gtag('event', 'email_click', {
                        'email_address': this.getAttribute('href').replace('mailto:', '')
                    });
                }
            });
        });
    }
    
    // Intersection Observer for Animations
    function setupIntersectionObserver() {
        const animatedElements = document.querySelectorAll('.service-card, .stat, .testimonial-card');
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('fade-in', 'visible');
                    observer.unobserve(entry.target);
                }
            });
        }, {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        });
        
        animatedElements.forEach(element => {
            element.classList.add('fade-in');
            observer.observe(element);
        });
    }
    
    // Navbar Scroll Effect (removed background color changes)
    function setupNavbarScrollEffect() {
        const navbar = document.querySelector('.navbar');
        let lastScrollY = window.scrollY;
        
        window.addEventListener('scroll', () => {
            const currentScrollY = window.scrollY;
            
            // Hide/show navbar on scroll
            if (currentScrollY > lastScrollY && currentScrollY > 300) {
                navbar.style.transform = 'translateY(-100%)';
            } else {
                navbar.style.transform = 'translateY(0)';
            }
            
            lastScrollY = currentScrollY;
        });
    }
    
    // Scroll to Top Button
    function setupScrollToTopButton() {
        // Create scroll to top button
        const scrollTopBtn = document.createElement('button');
        scrollTopBtn.innerHTML = '↑';
        scrollTopBtn.className = 'scroll-top-btn';
        scrollTopBtn.setAttribute('aria-label', 'Scroll to top');
        document.body.appendChild(scrollTopBtn);
        
        // Show/hide button based on scroll position
        window.addEventListener('scroll', () => {
            if (window.scrollY > 300) {
                scrollTopBtn.classList.add('visible');
            } else {
                scrollTopBtn.classList.remove('visible');
            }
        });
        
        // Scroll to top when clicked
        scrollTopBtn.addEventListener('click', () => {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
    
    // Notification System
    function showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        // Show notification
        setTimeout(() => {
            notification.classList.add('show');
        }, 100);
        
        // Hide and remove notification
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, 4000);
    }
    
    window.JAMConstruction = {
        validateField,
        showNotification,
        trackLeadGeneration
    };

})();