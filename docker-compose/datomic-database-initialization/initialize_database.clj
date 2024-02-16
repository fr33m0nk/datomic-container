(require '[datomic.api :as d])
(import '[clojure.lang ExceptionInfo])

(def DATOMIC_DB_NAME (System/getenv "DATOMIC_DB_NAME"))

(def PG_HOST (System/getenv "PG_HOST"))

(def PG_PORT (System/getenv "PG_PORT"))

(def PG_DATABASE (System/getenv "PG_DATABASE"))

(def PG_USER (System/getenv "PG_USER"))

(def PG_PASSWORD (System/getenv "PG_PASSWORD"))

(def uri (format "datomic:sql://%s?jdbc:postgresql://%s:%s/%s?user=%s&password=%s"
           DATOMIC_DB_NAME PG_HOST PG_PORT PG_DATABASE PG_USER PG_PASSWORD))

(defn database-migrator
  [uri]
  (println "The URI is " uri)
  (try
    (let [db-created? (d/create-database uri)]
      (if db-created?
        (do
          (println "Database successfully created in Datomic")
          :db-created)
        (do
          (printf "Database already exists in Datomic.\nNothing more to do\n")
          :db-exists)))
    (catch Throwable t
      (println "Failed to create database in datomic. Reason:")
      (if-not (instance? ExceptionInfo t)
        (println (Throwable->map t)
        (do
          (println (ex-message t))
          (println (ex-data t)))))
      :error)))

(defn create-db-in-datomic
  ([uri retries]
   (create-db-in-datomic uri retries 0))
  ([uri retries counter]
   (if (> counter retries)
     (do
       (println "Retries exhausted!!")
       (System/exit 1))
     (let [result (database-migrator uri)]
          (if (#{:db-created :db-exists} result)
            (System/exit 0)
            (let [delay-ms 5000]
              (println "Retrying in " (/ delay-ms 1000) " seconds")
              (Thread/sleep delay-ms)
              (recur uri retries (inc counter))))))))

(->> (System/getenv "RETRIES") parse-long (create-db-in-datomic uri))
