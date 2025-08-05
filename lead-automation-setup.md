# JAM Construction - Lead Generation Automation Setup

## Phase 1: Immediate Setup (24 hours)

### Form Handling with Formspree
1. **Sign up at formspree.io**
   - Create account
   - Create new form
   - Get your form endpoint: `https://formspree.io/f/YOUR_FORM_ID`

2. **Update your website form**
   ```html
   <form id="contact-form" action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
       <input type="hidden" name="_subject" value="New Lead from jamconst.com">
       <input type="hidden" name="_next" value="https://jamconst.com/thank-you.html">
       <!-- your existing fields -->
   </form>
   ```

3. **Create thank-you page**
   ```html
   <!-- /var/www/html/thank-you.html -->
   <!DOCTYPE html>
   <html>
   <head>
       <title>Thank You - JAM Construction</title>
       <meta http-equiv="refresh" content="3;url=https://jamconst.com">
   </head>
   <body>
       <h1>Thank You!</h1>
       <p>We'll contact you within 24 hours.</p>
   </body>
   </html>
   ```

## Phase 2: Email Automation (Week 1)

### Zapier Integration
1. **Connect Formspree to Zapier**
   - Trigger: New Formspree submission
   - Action: Multiple actions

2. **Automated Email Responses**
   ```
   Zap 1: Instant Response
   Trigger: New Formspree submission
   Action: Send email via Gmail
   Template: "Thanks for your interest. We'll contact you within 24 hours."
   
   Zap 2: Add to CRM
   Trigger: New Formspree submission  
   Action: Create row in Google Sheets
   Data: Name, email, phone, project details, timestamp
   
   Zap 3: Sales Notification
   Trigger: New Formspree submission
   Action: Send SMS via Twilio
   Message: "New lead: [Name] - [Project Type] - [Budget]"
   ```

### Email Templates
```html
<!-- Immediate Response Template -->
Subject: Your Construction Estimate Request - JAM Construction

Hi [Name],

Thank you for contacting JAM Construction for your construction estimating needs.

We've received your project details:
- Project Type: [Project Type]
- Location: [Location] 
- Timeline: [Timeline]

What happens next:
1. We'll review your project details (within 4 hours)
2. One of our estimators will call you (within 24 hours)  
3. We'll schedule a project consultation if needed
4. You'll receive your detailed estimate (within 48 hours)

Questions? Reply to this email or call us at (612) XXX-XXXX

Best regards,
JAM Construction Team
```

## Phase 3: Advanced CRM Setup (Week 2-3)

### HubSpot Free CRM Integration
1. **Setup HubSpot Free CRM**
   ```javascript
   // Add to your website
   <script type="text/javascript" id="hs-script-loader" async defer src="//js.hs-scripts.com/YOUR_HUB_ID.js"></script>
   ```

2. **Lead Scoring System**
   ```
   High Priority (Contact within 2 hours):
   - Commercial projects >$100k
   - "ASAP" timeline
   - Government projects
   
   Medium Priority (Contact within 24 hours):
   - Residential >$50k
   - 1-3 month timeline
   
   Low Priority (Contact within 48 hours):
   - Small projects <$50k
   - 6+ month timeline
   ```

### Follow-up Automation Sequence
```
Day 0: Immediate response (automated)
Day 1: Personal call attempt + email
Day 3: Follow-up email with portfolio
Day 7: Final follow-up with special offer
Day 30: Monthly newsletter signup
```

## Phase 4: Advanced Analytics (Month 2)

### Google Analytics Enhanced Ecommerce
```javascript
// Track form submissions as conversions
gtag('event', 'conversion', {
    'send_to': 'AW-CONVERSION_ID/CONVERSION_LABEL',
    'value': estimatedProjectValue,
    'currency': 'USD'
});
```

### Lead Source Tracking
```javascript
// Add to your JavaScript
function trackLeadSource() {
    const urlParams = new URLSearchParams(window.location.search);
    const source = urlParams.get('utm_source') || 'direct';
    const medium = urlParams.get('utm_medium') || 'organic';
    
    // Store in form as hidden fields
    document.getElementById('lead-source').value = source;
    document.getElementById('lead-medium').value = medium;
}
```

## Cost Breakdown

### Monthly Costs:
- **Formspree Pro**: $10/month (1000 submissions)
- **Zapier Starter**: $20/month (750 tasks)
- **HubSpot CRM**: Free (up to 1,000,000 contacts)
- **Twilio SMS**: $0.0075/SMS
- **Total**: ~$30-40/month

### ROI Calculation:
```
If you get 20 leads/month and convert 20% (4 projects):
- Average project value: $2,500 (estimate fee)
- Monthly revenue: $10,000
- ROI: $10,000 / $40 = 25,000% ROI
```

## Implementation Checklist

### Week 1:
- [ ] Set up Formspree account
- [ ] Update website forms
- [ ] Create thank-you page
- [ ] Test form submissions
- [ ] Set up basic Zapier automation

### Week 2:
- [ ] Create email templates
- [ ] Set up Google Sheets lead tracking
- [ ] Configure SMS notifications
- [ ] Test entire workflow
- [ ] Set up Google Analytics goals

### Week 3:
- [ ] Implement HubSpot CRM
- [ ] Create lead scoring system
- [ ] Set up follow-up sequences
- [ ] Train team on new process
- [ ] Create reporting dashboard

### Month 2:
- [ ] Analyze lead quality and sources
- [ ] Optimize conversion rates
- [ ] A/B test email templates
- [ ] Expand to additional channels
- [ ] Scale successful strategies

## Emergency Backup Plan

If any service goes down:
1. **Form backup**: Contact forms email directly to your Gmail
2. **CRM backup**: Google Sheets with all lead data
3. **Communication backup**: Phone calls for urgent leads
4. **Process backup**: Manual follow-up checklist

## Success Metrics to Track

### Daily:
- New leads received
- Response time to leads
- Form conversion rate

### Weekly:
- Lead-to-customer conversion rate
- Average project value
- Revenue per lead

### Monthly:
- Cost per lead
- Customer lifetime value
- ROI of automation system

This system will capture, nurture, and convert leads automatically while you focus on delivering great estimates and growing your business.