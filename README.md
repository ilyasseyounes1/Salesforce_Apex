# Salesforce Apex & Integration Showcase

This repository is a comprehensive collection of Salesforce development examples, covering a wide array of topics from Apex fundamentals to advanced API integrations and UI development. It serves as a practical guide and a showcase of best practices within the Salesforce ecosystem.

## Core Concepts Covered

*   **Apex Fundamentals & Data Manipulation:** Demonstrations of collections (Lists, Sets, Maps), SOQL, SOSL, and a variety of DML operations (`insert`, `update`, `upsert`, `delete`).
*   **Apex Triggers:** Implementation of the trigger handler pattern, recursion control techniques, and context variable usage for various DML events.
*   **Asynchronous Apex:** Examples of `@future`, `Queueable`, `Batchable`, and `Schedulable` Apex for handling long-running processes, callouts, and large data volumes.
*   **Comprehensive API Integration:** An extensive library of integration patterns, including:
    *   **Inbound & Outbound REST:** Creating custom Apex REST services and making HTTP callouts, handling authentication with Named Credentials and OAuth 2.0.
    *   **Bulk API 2.0:** Programmatically creating and managing jobs to insert large datasets.
    *   **Streaming API:** Using PushTopics and CometD clients (in Java & Node.js) for real-time event monitoring and dashboards.
    *   **Advanced APIs:** Examples using the Composite API for bundled requests, GraphQL API for precise data queries, Metadata API for programmatic customization, and Connect API for Experience Cloud.
*   **UI Frameworks:** Examples for Lightning Web Components (LWC), Aura Components, and Visualforce. LWC examples cover component lifecycle, data binding, and parent-child communication.
*   **Apex Testing:** Best practices for unit testing, including data factories, `@TestSetup`, `@TestVisible`, `runAs()`, and `HttpCalloutMock` for testing integrations.
*   **MuleSoft API Design:** Includes RAML files for designing and specifying APIs in MuleSoft's Anypoint Platform, showcasing an API-first approach to integration.

## Repository Structure

This repository is organized into two main sections:

### Salesforce_APEX/

This directory contains the core Salesforce code, categorized by function and feature.

*   `Apex REST API Integration/`: A deep dive into various Salesforce APIs with detailed Apex classes for callouts and services. Includes notes on integration overviews and authentication.
*   `Asynchronous_Apex/`: Code for different asynchronous processing methods (Future, Queueable, Batch, Schedulable).
*   `Apex Triggers/`: Well-structured trigger examples with handler classes that demonstrate bulkification and recursion prevention.
*   `Lightning Web Components (LWC)/`: Modern UI components demonstrating key features like data binding, lifecycle hooks, and event handling.
*   `Apex Testing/`: Test classes that showcase best practices for code coverage and testing asynchronous and callout logic.
*   `SOQL & SOSL/`: Examples of simple and advanced queries, including aggregate functions, relationship queries, and search.
*   `Fondamentals/`, `Loops/`, `Maps/`, `Sets/`: Classes covering the foundational concepts of the Apex language.
*   `Visualforce/` & `Lightning Aura Components/`: Legacy and classic UI development examples.

### MuleSoft_AnyPoint_Platform/

This section contains RAML (RESTful API Modeling Language) files which define API specifications.

*   `Lv19_RAML Design & API Specification/`: Defines a `Customer API` with standard CRUD operations.
*   `Lv19_RAML_Sys-bank-API/`: A more complex system API for banking operations, demonstrating the use of resource types and traits.
