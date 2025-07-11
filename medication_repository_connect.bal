import ballerina/http;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.international401;

isolated international401:Medication[] medications = [];
isolated int createOperationNextIdMedication = 20001;

public isolated function createMedication(international401:Medication medication) returns r4:FHIRError|international401:Medication {
    lock {
        createOperationNextIdMedication += 1;
        medication.id = (createOperationNextIdMedication).toBalString();
    }
    lock {
        medications.push(medication.clone());
    }
    return medication;
}

public isolated function getByIdMedication(string id) returns r4:FHIRError|international401:Medication {
    lock {
        foreach var item in medications {
            if item.id == id {
                return item.clone();
            }
        }
    }
    return r4:createFHIRError(string `Cannot find a Medication resource with id: ${id}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_FOUND);
}

public isolated function searchMedication(map<string[]>? searchParameters = ()) returns r4:FHIRError|r4:Bundle {
    r4:Bundle bundle = {
        'type: "collection"
    };

    if searchParameters is map<string[]> {
        string? id = ();
        string? code = ();

        foreach var 'key in searchParameters.keys() {
            match 'key {
                "_id" => {
                    id = searchParameters.get('key)[0];
                }
                "code" => {
                    code = searchParameters.get('key)[0];
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

        international401:Medication[] results;
        lock {
            results = medications.clone();
        }

        if id is string {
            international401:Medication byId = check getByIdMedication(id);
            results = [byId];
        }

        if code is string {
            results = getByCodeMedication(code, results);
        }

        r4:BundleEntry[] bundleEntries = [];
        foreach international401:Medication item in results {
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

isolated function getByCodeMedication(string code, international401:Medication[] medications) returns international401:Medication[] {
    international401:Medication[] filteredMedications = [];
    foreach international401:Medication medication in medications {
        if medication.code is r4:CodeableConcept {
            r4:CodeableConcept codeableConcept = <r4:CodeableConcept>medication.code;
            if codeableConcept.coding is r4:Coding[] {
                r4:Coding[] codings = <r4:Coding[]>codeableConcept.coding;
                foreach r4:Coding coding in codings {
                    if coding.code == code {
                        filteredMedications.push(medication);
                        break;
                    }
                }
            }
        }
    }
    return filteredMedications;
}

function initMedication() returns error? {
    lock {
        international401:Medication medicationJson1 = {
            id: "1049630",
            resourceType: "Medication",
            meta: {
                lastUpdated: "2023-10-01T12:00:00Z"
            },
            code: {
                coding: [
                    {
                        system: "http://www.nlm.nih.gov/research/umls/rxnorm",
                        code: "1049630",
                        display: "Atorvastatin 20 MG Oral Tablet"
                    }
                ]
            }
        };
        medications.push(medicationJson1);

        international401:Medication medicationJson2 = {
            id: "617314",
            resourceType: "Medication",
            meta: {
                lastUpdated: "2023-10-01T12:00:00Z"
            },
            code: {
                coding: [
                    {
                        system: "http://www.nlm.nih.gov/research/umls/rxnorm",
                        code: "617314",
                        display: "Metformin 500 MG Oral Tablet"
                    }
                ]
            }
        };
        medications.push(medicationJson2);

        international401:Medication medicationJson3 = {
            id: "123456",
            resourceType: "Medication",
            meta: {
                lastUpdated: "2023-10-01T12:00:00Z"
            },
            code: {
                coding: [
                    {
                        system: "http://www.nlm.nih.gov/research/umls/rxnorm",
                        code: "123456",
                        display: "Example Medication"
                    }
                ]
            }
        };
        medications.push(medicationJson3);
    }
}