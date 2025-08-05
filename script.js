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
                navMenu.classList.toggle('active');
                mobileToggle.classList.toggle('active');
            });
            
            // Close menu when clicking on nav links (mobile)
            const navLinks = document.querySelectorAll('.nav-menu a');
            navLinks.forEach(link => {
                link.addEventListener('click', function() {
                    navMenu.classList.remove('active');
                    mobileToggle.classList.remove('active');
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
        e.preventDefault();
        
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
        
        if (isValid) {
            // Show loading state
            const submitButton = form.querySelector('button[type="submit"]');
            const originalText = submitButton.textContent;
            submitButton.textContent = 'Sending...';
            submitButton.disabled = true;
            
            // Simulate form submission (replace with actual API call)
            setTimeout(() => {
                if (form.id === 'quote-form') {
                    handleQuoteFormSubmission(formData);
                } else if (form.id === 'contact-form') {
                    handleContactFormSubmission(formData);
                }
                
                // Reset button
                submitButton.textContent = originalText;
                submitButton.disabled = false;
                
                // Reset form
                form.reset();
                clearAllFieldErrors(form);
                
                // Show success message
                showNotification('Thank you! We\'ll get back to you within 24 hours.', 'success');
                
                // Track conversion
                trackLeadGeneration(form.id, formData);
                
            }, 2000);
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
    
    function clearAllFieldErrors(form) {
        const fieldGroups = form.querySelectorAll('.form-group');
        fieldGroups.forEach(group => {
            group.classList.remove('error', 'success');
            const errorMessage = group.querySelector('.error-message');
            if (errorMessage) {
                errorMessage.textContent = '';
            }
        });
    }
    
    // Lead Generation Tracking
    function handleQuoteFormSubmission(formData) {
        const leadData = {
            type: 'quote_request',
            name: formData.get('name'),
            email: formData.get('email'),
            phone: formData.get('phone'),
            projectType: formData.get('project-type'),
            budget: formData.get('budget'),
            timeline: formData.get('timeline'),
            message: formData.get('message'),
            timestamp: new Date().toISOString(),
            source: 'website',
            page: window.location.pathname
        };
        
        // Store lead data (replace with actual database/API call)
        storeLeadData(leadData);
        
        // Send notification email (replace with actual email service)
        console.log('Quote Request Submitted:', leadData);
    }
    
    function handleContactFormSubmission(formData) {
        const leadData = {
            type: 'contact_inquiry',
            name: formData.get('name'),
            email: formData.get('email'),
            phone: formData.get('phone'),
            subject: formData.get('subject'),
            message: formData.get('message'),
            timestamp: new Date().toISOString(),
            source: 'website',
            page: window.location.pathname
        };
        
        // Store lead data
        storeLeadData(leadData);
        
        console.log('Contact Form Submitted:', leadData);
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
        // Google Analytics Event Tracking
        if (typeof gtag !== 'undefined') {
            gtag('event', 'lead_generation', {
                'form_id': formId,
                'project_type': formData.get('project-type') || 'contact',
                'lead_value': calculateLeadValue(formData.get('budget'))
            });
        }
        
        // Facebook Pixel Event (if using Facebook Ads)
        if (typeof fbq !== 'undefined') {
            fbq('track', 'Lead', {
                content_name: formId === 'quote-form' ? 'Quote Request' : 'Contact Form',
                value: calculateLeadValue(formData.get('budget')),
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
        const animatedElements = document.querySelectorAll('.service-card, .feature, .stat');
        
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
    
    // Navbar Scroll Effect
    function setupNavbarScrollEffect() {
        const navbar = document.querySelector('.navbar');
        let lastScrollY = window.scrollY;
        
        window.addEventListener('scroll', () => {
            const currentScrollY = window.scrollY;
            
            if (currentScrollY > 100) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
            
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
    
    // Utility Functions
    function debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
    
    // Preload Critical Images
    function preloadImages() {
        const images = [
            // Add your critical images here
        ];
        
        images.forEach(src => {
            const img = new Image();
            img.src = src;
        });
    }
    
    // Initialize preloading
    preloadImages();
    
    // Export functions for testing (if needed)
    window.JAMConstruction = {
        validateField,
        showNotification,
        trackLeadGeneration
    };
    
})();

// Additional CSS for scroll-to-top button and notifications
const additionalStyles = `
.scroll-top-btn {
    position: fixed;
    bottom: 20px;
    right: 20px;
    width: 50px;
    height: 50px;
    background-color: var(--primary-color);
    color: white;
    border: none;
    border-radius: 50%;
    font-size: 18px;
    cursor: pointer;
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s ease;
    z-index: 1000;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.scroll-top-btn.visible {
    opacity: 1;
    visibility: visible;
}

.scroll-top-btn:hover {
    background-color: var(--secondary-color);
    transform: translateY(-2px);
}

.notification {
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 16px 24px;
    border-radius: 8px;
    color: white;
    font-weight: 600;
    opacity: 0;
    transform: translateX(100%);
    transition: all 0.3s ease;
    z-index: 1001;
    max-width: 400px;
}

.notification.show {
    opacity: 1;
    transform: translateX(0);
}

.notification-success {
    background-color: var(--success-color);
}

.notification-error {
    background-color: var(--error-color);
}

.notification-info {
    background-color: var(--primary-color);
}

.navbar.scrolled {
    background: rgba(30, 58, 138, 0.95);
    backdrop-filter: blur(20px);
}

@media (max-width: 768px) {
    .nav-menu.active {
        display: flex;
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background: var(--primary-color);
        flex-direction: column;
        padding: 1rem;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    
    .mobile-menu-toggle.active span:nth-child(1) {
        transform: rotate(45deg) translate(5px, 5px);
    }
    
    .mobile-menu-toggle.active span:nth-child(2) {
        opacity: 0;
    }
    
    .mobile-menu-toggle.active span:nth-child(3) {
        transform: rotate(-45deg) translate(7px, -6px);
    }
}
`;

// Inject additional styles
const styleSheet = document.createElement('style');
styleSheet.textContent = additionalStyles;
document.head.appendChild(styleSheet);