CREATE Temporary TABLE product_params (
    ID SERIAL PRIMARY KEY,
    ProcessCode VARCHAR(10),
    IN_APPL_APPLICATIONID INT,
    IN_CURRATES_CURRENCYID INT,
    IN_CURRATES_RATE NUMERIC(10, 3),
    IN_PRODUCT_TYPE VARCHAR(10),
    IN_PRODUCT_PARAMS_RECNUMBER INT,
    IN_PRODUCT_PARAMS_NAME VARCHAR(50),
    IN_PRODUCT_PARAMS_VALUE VARCHAR(100)
);


DO $$
DECLARE
	ProcessCode VARCHAR(10);
    IN_APPL_APPLICATIONID INT;
    IN_CURRATES_CURRENCYID INT;
    IN_CURRATES_RATE NUMERIC(10, 3);
    IN_PRODUCT_TYPE VARCHAR(10);
    IN_PRODUCT_PARAMS_RECNUMBER INT;
    IN_PRODUCT_PARAMS_NAME VARCHAR(50);
    IN_PRODUCT_PARAMS_VALUE VARCHAR(100);
	record XML;
	xml_data XML := 
		'<Request>
			<Header>
				<InquiryCode>2115</InquiryCode>
				<ProcessCode>T12</ProcessCode>
				<OrganizationCode>UBP</OrganizationCode>
				<LayoutVersion>6</LayoutVersion>
			</Header>
			<Body>
				<Application>
					<Variables>
						<IN_APPL_APPLICATIONID>2115</IN_APPL_APPLICATIONID>
						<IN_APPL_CAMPAIGN_CODE>ToOkcU0YBhXtFNGt2Fzhs</IN_APPL_CAMPAIGN_CODE>
						<IN_APPL_CREATE_DATE>2023-08-18</IN_APPL_CREATE_DATE>
						<IN_APPL_CREATE_TIME>70905</IN_APPL_CREATE_TIME>
						<IN_APPL_ITERNUM>3</IN_APPL_ITERNUM>
						<IN_APPL_REQUEST_TYPE>PREAP_internal</IN_APPL_REQUEST_TYPE>
						<IN_APPL_S1_STEP>C_1_020</IN_APPL_S1_STEP>
						<IN_APPL_SALES_TARGET>finOborKapit</IN_APPL_SALES_TARGET>
						<IN_APPL_STAGE_NAME>PREAP_internal</IN_APPL_STAGE_NAME>
						<IN_APPL_TEST_FLAG>1</IN_APPL_TEST_FLAG>
						<IN_APPL_TYPE>avocc-credit</IN_APPL_TYPE>
						<IN_APPL_CREATE_DATETIME>2023-08-18 19:41:45</IN_APPL_CREATE_DATETIME>
						<IN_XSLT_VER>1.3</IN_XSLT_VER>
						<IN_NO_GUARANTOR_FLAG>1</IN_NO_GUARANTOR_FLAG>
					</Variables>
					<Categories>
						<CURRATES>
							<Variables>
								<IN_CURRATES_CURRENCYID>810</IN_CURRATES_CURRENCYID>
								<IN_CURRATES_RATE>0.996</IN_CURRATES_RATE>
							</Variables>
						</CURRATES>
						<PRODUCT>
							<Variables>
								<IN_PRODUCT_RECNUMBER>1</IN_PRODUCT_RECNUMBER>
								<IN_PRODUCT_COMMITTEE_APR>10</IN_PRODUCT_COMMITTEE_APR>
								<IN_PRODUCT_CREDIT_SUM>1000.00</IN_PRODUCT_CREDIT_SUM>
								<IN_PRODUCT_CREDIT_TERM>60</IN_PRODUCT_CREDIT_TERM>
								<IN_PRODUCT_ID>iv8cJjuhdV1boPI2yivEd</IN_PRODUCT_ID>
								<IN_PRODUCT_TYPE>BBP</IN_PRODUCT_TYPE>
							</Variables>
							<Categories>
								<PRODUCT_PARAMS>
									<Variables>
										<IN_PRODUCT_PARAMS_RECNUMBER>1</IN_PRODUCT_PARAMS_RECNUMBER>
										<IN_PRODUCT_PARAMS_NAME>TARIFFNAME</IN_PRODUCT_PARAMS_NAME>
										<IN_PRODUCT_PARAMS_VALUE>Бизнес-Блиц предодобренный</IN_PRODUCT_PARAMS_VALUE>
									</Variables>
								</PRODUCT_PARAMS>
								<PRODUCT_PARAMS>
									<Variables>
										<IN_PRODUCT_PARAMS_RECNUMBER>2</IN_PRODUCT_PARAMS_RECNUMBER>
										<IN_PRODUCT_PARAMS_NAME>TARIFFID</IN_PRODUCT_PARAMS_NAME>
										<IN_PRODUCT_PARAMS_VALUE>credit_businessBlitzP</IN_PRODUCT_PARAMS_VALUE>
									</Variables>
								</PRODUCT_PARAMS>
							</Categories>
						</PRODUCT>
					</Categories>
				</Application>
			</Body>
		</Request>';
	path_header varchar := '/Request/Header';
	path_body varchar := '/Request/Body';
	path_application varchar := concat(path_body, '/Application');
	path_variables varchar := concat(path_application, '/Variables');
	path_categories varchar := concat(path_application, '/Categories');
	path_product varchar := concat(path_categories, '/PRODUCT');
    path_product_params varchar := concat(path_product, '/Categories/PRODUCT_PARAMS');
BEGIN
	FOR record IN SELECT unnest(xpath('/Request/Body/Application/Categories/PRODUCT/Categories/PRODUCT_PARAMS', xml_data)) LOOP
		ProcessCode := (xpath(path_header || '/ProcessCode/text()', xml_data))[1]::text::varchar;
		IN_APPL_APPLICATIONID := (xpath(path_variables || '/IN_APPL_APPLICATIONID/text()', xml_data))[1]::text::INT;
	    IN_CURRATES_CURRENCYID := (xpath(path_categories || '/CURRATES/Variables/IN_CURRATES_CURRENCYID/text()', xml_data))[1]::text::INT;
	    IN_CURRATES_RATE := (xpath(path_categories || '/CURRATES/Variables/IN_CURRATES_RATE/text()', xml_data))[1]::text::numeric;
	    IN_PRODUCT_TYPE := (xpath(path_product || '/Variables/IN_PRODUCT_TYPE/text()', xml_data))[1]::text::varchar;
	    IN_PRODUCT_PARAMS_RECNUMBER := (xpath('/PRODUCT_PARAMS/Variables/IN_PRODUCT_PARAMS_RECNUMBER/text()', record))[1]::text::INT;
	    IN_PRODUCT_PARAMS_NAME := (xpath('/PRODUCT_PARAMS/Variables/IN_PRODUCT_PARAMS_NAME/text()', record))[1]::text::varchar;
	    IN_PRODUCT_PARAMS_VALUE := (xpath('/PRODUCT_PARAMS/Variables/IN_PRODUCT_PARAMS_VALUE/text()', record))[1]::text::varchar;

	INSERT INTO product_params (
        ProcessCode,
        IN_APPL_APPLICATIONID,
        IN_CURRATES_CURRENCYID,
        IN_CURRATES_RATE,
        IN_PRODUCT_TYPE,
        IN_PRODUCT_PARAMS_RECNUMBER,
        IN_PRODUCT_PARAMS_NAME,
        IN_PRODUCT_PARAMS_VALUE
    ) VALUES (
        ProcessCode,
        IN_APPL_APPLICATIONID,
        IN_CURRATES_CURRENCYID,
        IN_CURRATES_RATE,
        IN_PRODUCT_TYPE,
        IN_PRODUCT_PARAMS_RECNUMBER,
        IN_PRODUCT_PARAMS_NAME,
        IN_PRODUCT_PARAMS_VALUE
    );
END LOOP;
END $$;

select * from product_params;