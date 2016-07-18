# Handover

The commercial software business has grown to huge proportions and every enterprise is virtually running to profit because of these low cost, high benefit solutions. Customers have increased to the number of a few billions who use these services everyday. Some of the major areas of concern here are quality of service, availability and customer support. The customer support space has numerous software solutions, but most of them cannot serve the grieving customers faster as they lack the decision making talent. 

Handover is an automatic support request escalation system which can escalate an incoming request to the appropriate support agent level, thereby eliminating the latency of solution. Handover uses the powerful technique of Decision trees to do this.

# Features used

For building any decision making system, it is important to have meaningful and interpretable features. We extract the information from the CSV dataset and classify it based on 3 main features. The main idea behind this is that we do not need a lot of data to make a great classifier. It is enough that we extract those features which actually matter and still give an amazing classification. We feel that these 3 features are enough to give good results for the problem at hand.

# Ticket Text
We get the ticket text in the csv file as plain text with no encoding. We proceed to use this ticket text to extract the sentiment of the ticket. We have defined a general corpus of words with related sentiment values. The whole ticket text is taken, the sentiment value for each word is collected and the value of the whole text is normalized to a value between 0 and 1. We then use a defined threshold to set the mood of the ticket. We have 3 different moods - Positive, Negative and Neutral.We have used a gem called Sentimental - a pre-built ruby package which can classify based on a initial set of words. We have extended it to include domain based words.We have defined several domain based text files which can be included based on the customer’s business to get the exact mood of the end customer.

# Related Product Priority
We get the priority of the related product mentioned in the ticket from the customer. We can obtain this priority by getting the general product revenue and the related business model. But in many cases this need not be true as a company might have distant goals and strategies, which determine the importance of a product. So the wise thing would be not to guess the improtance and actually get this data from the customer.

# Customer Priority
The CSV data file contains the name of the customer who raised the ticket, the lifetime (time when he started using the product of the service) and the revenue attained (basically the net value of the customer). We then use the lifetime and the revenue to generate a customer priority. We normalize a score between 0 to 10 for each customer based on revenue first and then by value wherein the max revenue becomes 10, max lifetime becomes 10, min revenue becomes 0 and min lifetime becomes 0. We take an average of the priorities based on lifetime and revenue and then normalize it to a value between 0 and 10. This is the revenue of the customer. This is a very critical resource as in most cases, the support provided to the customer is based on the customer’s net value.

# The Classifier
We have built a custom decision tree classifier in Ruby. There are a few ready made decision tree generators in ruby but most wont fit our model and data. Hence, building one from scratch was the more logical option. We have built a decision tree classifier which is partially ID3. The actual ordering of features is not information gain based. The sentiment value of the ticket text play the higher role and hence is the most significant feature. Next comes the product priority as the truth in business is that the product in interest is the one where most of the resources are put to use. The third is the customer priority value. We then segregate the result values based on the information gain and build a tree. This tree is specific for a given customer and for a given dataset. So in general, the same customer can define several decision trees by uploading several sets of data and he can use the appropriate ones.

# How to use

You can download and start the application like just any other rails application. No Frills!!
Initially, the Business owner or the Handover customer takes the historical data from their Customer Support Application and then uploads it in CSV format to the Handover’s upload page. This CSV data must contain customer name, customer revenue, customer lifetime, related product priority, ticket text and the final escalation level of the ticket. Then the Handover application uses this data to build a decision tree in a background job. The customer can upload multiple versions of the data and generate a decision tree for each. The decision trees of the customer can be viewed under the decision tree tab.
The decision trees will also have an URL associated with it which can be used for getting the classification. When the end customer raises a ticket at the Customer Support Application, these request details are given as API calls to the handover application to that specified URL. They should enclose the parameters in a key called ”test” which will have 3 fields ”ticket text”, ”customer priority” and ”related product priority”.
The customer priority is calculated at the time of the decision tree construction. This is stored in a dataset and is readily available for the customer.
Handover then uses this decision tree along with the test data and predicts a escalation level which is sent as response. This response is fetched by the user’s customer support application and the appropriate escalation level is set.

A demo can be seen live at https://morning-waters-93736.herokuapp.com/ (Due to lack of credits the background job of creating a tree will not run. But you can get a general look and feel of the software here. One can definitely pull it and run locally for complete results)