
import ballerina/http;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.international401;

isolated international401:Immunization[] immunizations = [];
isolated int createOperationNextIdImmunization = 40001;

public isolated function createImmunization(international401:Immunization immunization) returns r4:FHIRError|international401:Immunization {
    lock {
        createOperationNextIdImmunization += 1;
        immunization.id = (createOperationNextIdImmunization).toBalString();
    }
    lock {
        immunizations.push(immunization.clone());
    }
    return immunization;
}

public isolated function getByIdImmunization(string id) returns r4:FHIRError|international401:Immunization {
    lock {
        foreach var item in immunizations {
            if item.id == id {
                return item.clone();
            }
        }
    }
    return r4:createFHIRError(string `Cannot find an Immunization resource with id: ${id}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_FOUND);
}

public isolated function searchImmunization(map<string[]>? searchParameters = ()) returns r4:FHIRError|r4:Bundle {
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
                "_count" => {
                    // pagination is not used in this service
                    continue;
                }
                _ => {
                    return r4:createFHIRError(string `Not supported search parameter: ${'key}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_IMPLEMENTED);
                }
            }
        }

        international401:Immunization[] results;
        lock {
            results = immunizations.clone();
        }

        if id is string {
            international401:Immunization byId = check getByIdImmunization(id);
            results = [byId];
        }

        if patient is string {
            results = getByPatientImmunization(patient, results);
        }

        r4:BundleEntry[] bundleEntries = [];
        foreach international401:Immunization item in results {
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

isolated function getByPatientImmunization(string patient, international401:Immunization[] immunizations) returns international401:Immunization[] {
    international401:Immunization[] filteredImmunizations = [];
    foreach international401:Immunization immunization in immunizations {
        if immunization.patient.reference == string `Patient/${patient}` {
            filteredImmunizations.push(immunization);
        }
    }
    return filteredImmunizations;
}

function initImmunization() returns error? {
    lock {
        international401:Immunization immunization1 = {
            "resourceType": "Immunization",
            "id": "40001",
            "meta": {
                "profile": [
                    "http://hl7.org/fhir/StructureDefinition/Immunization"
                ]
            },
            "status": "completed",
            "vaccineCode": {
                "coding": [
                    {
                        "system": "http://hl7.org/fhir/sid/cvx",
                        "code": "207",
                        "display": "COVID-19, mRNA, LNP-S, PF, 100 mcg/0.5 mL dose"
                    }
                ],
                "text": "COVID-19 Vaccine"
            },
            "patient": {
                "reference": "Patient/101"
            },
            "occurrenceDateTime": "2023-01-10",
            "occurrenceString": "2023-01-10",
            "primarySource": true
        };
        immunizations.push(immunization1);

        international401:Immunization immunization2 = {
            "resourceType": "Immunization",
            "id": "40002",
            "meta": {
                "profile": [
                    "http://hl7.org/fhir/StructureDefinition/Immunization"
                ]
            },
            "status": "completed",
            "vaccineCode": {
                "coding": [
                    {
                        "system": "http://hl7.org/fhir/sid/cvx",
                        "code": "140",
                        "display": "Influenza, seasonal, injectable, preservative free"
                    }
                ],
                "text": "Influenza Vaccine"
            },
            "patient": {
                "reference": "Patient/102"
            },
            "occurrenceDateTime": "2022-11-05",
            "occurrenceString": "2022-11-05",
            "primarySource": true
        };
        
        immunizations.push(immunization2);
    }
}
