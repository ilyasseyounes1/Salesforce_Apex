// studentProfileCard.js
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

// Define the fields we want to fetch (if using with Contact records)
const FIELDS = ['Contact.Name', 'Contact.Email', 'Contact.Phone'];

export default class StudentProfileCard extends LightningElement {
    // @api - Public properties that parent components can set
    @api studentId; // Can be set from parent: <c-student-profile-card student-id="003XXXXXXX"></c-student-profile-card>
    @api cardTitle = 'Student Profile'; // Default value
    @api showContactInfo = false; // Boolean property (must default to false)
    
    // @track - Reactive properties (optional in newer API versions for objects/arrays)
    @track studentStats = {
        coursesCompleted: 0,
        currentGrade: 'A',
        attendanceRate: 95
    };
    
    // Regular reactive properties (no decorator needed for primitives)
    isEditing = false;
    localName = '';
    
    // @wire - Reactive data from Salesforce
    @wire(getRecord, { recordId: '$studentId', fields: FIELDS })
    studentRecord;
    
    // Getters for computed properties
    get studentName() {
        return this.studentRecord?.data?.fields?.Name?.value || 'Loading...';
    }
    
    get studentEmail() {
        return this.studentRecord?.data?.fields?.Email?.value || 'No email';
    }
    
    get isDataLoaded() {
        return this.studentRecord?.data;
    }
    
    get hasError() {
        return this.studentRecord?.error;
    }
    
    get gradeClass() {
        const grade = this.studentStats.currentGrade;
        return grade === 'A' ? 'grade-excellent' : 
               grade === 'B' ? 'grade-good' : 'grade-needs-improvement';
    }
    
    // Event handlers demonstrating reactivity
    handleEditToggle() {
        this.isEditing = !this.isEditing;
        if (this.isEditing) {
            this.localName = this.studentName;
        }
    }
    
    handleNameChange(event) {
        this.localName = event.target.value;
    }
    
    handleUpdateStats() {
        // Updating tracked object properties
        this.studentStats = {
            ...this.studentStats,
            coursesCompleted: this.studentStats.coursesCompleted + 1,
            attendanceRate: Math.min(100, this.studentStats.attendanceRate + 1)
        };
    }
    
    handleGradeChange(event) {
        this.studentStats = {
            ...this.studentStats,
            currentGrade: event.target.value
        };
    }
    
    // Lifecycle method to demonstrate property access
    connectedCallback() {
        console.log('Component connected with studentId:', this.studentId);
        console.log('Card title:', this.cardTitle);
    }
}