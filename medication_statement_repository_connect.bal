import ballerina/http;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.international401;

isolated international401:MedicationStatement[] medicationStatements = [];
isolated int createOperationNextIdMedicationStatement = 30001;

public isolated function createMedicationStatement(international401:MedicationStatement medicationStatement) returns r4:FHIRError|international401:MedicationStatement {
    lock {
        createOperationNextIdMedicationStatement += 1;
        medicationStatement.id = (createOperationNextIdMedicationStatement).toBalString();
    }
    lock {
        medicationStatements.push(medicationStatement.clone());
    }
    return medicationStatement;
}

public isolated function getByIdMedicationStatement(string id) returns r4:FHIRError|international401:MedicationStatement {
    lock {
        foreach var item in medicationStatements {
            if item.id == id {
                return item.clone();
            }
        }
    }
    return r4:createFHIRError(string `Cannot find a MedicationStatement resource with id: ${id}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_FOUND);
}

public isolated function searchMedicationStatement(map<string[]>? searchParameters = ()) returns r4:FHIRError|r4:Bundle {
    r4:Bundle bundle = {
        'type: "collection"
    };

    if searchParameters is map<string[]> {
        string? id = ();
        string? patient = ();

        foreach var 'key in searchParameters.keys() {
            match 'key {
                "_id" => {
                    id = searchParameters.get('key)[0];
                }
                "patient" => {
                    patient = searchParameters.get('key)[0];
                }
                "subject" => {
                    patient = searchParameters.get('key)[0];
                }
                "_count" => {
                    // pagination is not used in this service
                    continue;
                }
                _ => {
                    return r4:createFHIRError(string `Not supported search parameter: ${'key}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_IMPLEMENTED);
                }
            }
        }

        international401:MedicationStatement[] results;
        lock {
            results = medicationStatements.clone();
        }

        if id is string {
            international401:MedicationStatement byId = check getByIdMedicationStatement(id);
            results = [byId];
        }

        if patient is string {
            results = getByPatientMedicationStatement(patient, results);
        }

        r4:BundleEntry[] bundleEntries = [];
        foreach international401:MedicationStatement item in results {
            r4:BundleEntry bundleEntry = {
                'resource: item
            };
            bundleEntries.push(bundleEntry);
        }

        bundle.entry = bundleEntries;
        bundle.total = results.length();
    }

    return bundle;
}

isolated function getByPatientMedicationStatement(string patient, international401:MedicationStatement[] medicationStatements) returns international401:MedicationStatement[] {
    international401:MedicationStatement[] filteredMedicationStatements = [];
    foreach international401:MedicationStatement medicationStatement in medicationStatements {
        if medicationStatement.subject.reference == string `Patient/${patient}` {
            filteredMedicationStatements.push(medicationStatement);
        }
    }
    return filteredMedicationStatements;
}

function initMedicationStatement() returns error? {
    lock {
        international401:MedicationStatement medicationStatementJson1 = {
            "resourceType": "MedicationStatement",
            "id": "30001",
            "meta": {
                "profile": [
                    "http://hl7.org/fhir/StructureDefinition/MedicationStatement"
                ]
            },
            "status": "active",
            "medicationCodeableConcept": {
                "coding": [
                    {
                        "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
                        "code": "1049630",
                        "display": "Atorvastatin 20 MG Oral Tablet"
                    }
                ],
                "text": "Atorvastatin 20 MG Oral Tablet"
            },
            "medicationReference": {
                "reference": "Medication/1049630"
            },
            "subject": {
                "reference": "Patient/102"
            },
            "effectiveDateTime": "2024-01-01",
            "dateAsserted": "2024-01-01",
            "informationSource": {
                "reference": "Practitioner/practitioner-456"
            },
            "dosage": [
                {
                    "text": "20 mg once daily"
                }
            ]
        };
        medicationStatements.push(medicationStatementJson1);

        international401:MedicationStatement medicationStatementJson2 = {
            "resourceType": "MedicationStatement",
            "id": "30002",
            "meta": {
                "profile": [
                    "http://hl7.org/fhir/StructureDefinition/MedicationStatement"
                ]
            },
            "status": "completed",
            "medicationCodeableConcept": {
                "coding": [
                    {
                        "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
                        "code": "617314",
                        "display": "Metformin 500 MG Oral Tablet"
                    }
                ],
                "text": "Metformin 500 MG Oral Tablet"
            },
            "medicationReference": {
                "reference": "Medication/617314"
            },
            "subject": {
                "reference": "Patient/101"
            },
            "effectiveDateTime": "2023-06-15",
            "dateAsserted": "2023-06-15",
            "informationSource": {
                "reference": "Practitioner/practitioner-123"
            },
            "dosage": [
                {
                    "text": "500 mg twice daily"
                }
            ]
        };
        medicationStatements.push(medicationStatementJson2);
    }
}
