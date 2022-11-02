import ballerinax/github;
import ballerina/http;

configurable string gitHubPat = ?;

github:ConnectionConfig config =  {
    auth: {token: gitHubPat}
};

type RepoStars record {
    string name;
    int stars;
};

# A service representing a network-accessible API
# bound to port `9090`.
 service / on new http:Listener(9090) {
    github:Client gc;

    function init() returns error? {
        self.gc = check new github:Client(config);
    }

    # A resource for generating greetings
    # + orgName - the input string name
    # + max - number of repos to return, defaults to -1, meaning all
    # + return - string name with hello message or error
    resource function get repos(string orgName, int max = 5) returns RepoStars[]|error {
        stream<github:Repository, github:Error?> repos = check self.gc->getRepositories(orgName, true);
        RepoStars[]? repoNames = check from var item in repos
            order by item.stargazerCount descending
            limit max
            select { name: item.name, stars: item.stargazerCount ?: -1};
        return repoNames ?: [];
    }
}
