-- DropForeignKey
ALTER TABLE "question_events" DROP CONSTRAINT "question_events_question_id_fkey";

-- DropForeignKey
ALTER TABLE "session_answers" DROP CONSTRAINT "session_answers_question_id_fkey";

-- DropIndex
DROP INDEX "question_events_session_id_idx";

-- AlterTable
ALTER TABLE "question_events" ADD COLUMN     "archived_at" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "questions" DROP CONSTRAINT "questions_pkey",
DROP COLUMN "id",
DROP COLUMN "text",
ADD COLUMN     "bloom_level" TEXT,
ADD COLUMN     "chapter" TEXT,
ADD COLUMN     "concept_ids" TEXT,
ADD COLUMN     "correct_reasoning" TEXT,
ADD COLUMN     "difficulty" INTEGER,
ADD COLUMN     "option_a" TEXT,
ADD COLUMN     "option_b" TEXT,
ADD COLUMN     "option_c" TEXT,
ADD COLUMN     "option_d" TEXT,
ADD COLUMN     "question_id" TEXT NOT NULL,
ADD COLUMN     "stem" TEXT NOT NULL,
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "wrong_a_confusion" TEXT,
ADD COLUMN     "wrong_b_confusion" TEXT,
ADD COLUMN     "wrong_c_confusion" TEXT,
ADD COLUMN     "wrong_d_confusion" TEXT,
ALTER COLUMN "quiz_id" DROP NOT NULL,
DROP COLUMN "question_type",
ADD COLUMN     "question_type" TEXT DEFAULT 'mcq',
ALTER COLUMN "options" DROP NOT NULL,
ALTER COLUMN "order_index" DROP NOT NULL,
ALTER COLUMN "order_index" SET DEFAULT 0,
ADD CONSTRAINT "questions_pkey" PRIMARY KEY ("question_id");

-- AlterTable
ALTER TABLE "quizzes" ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- AlterTable
ALTER TABLE "session_answers" DROP CONSTRAINT "session_answers_pkey",
DROP COLUMN "answer",
DROP COLUMN "last_updated",
DROP COLUMN "time_spent_ms",
ADD COLUMN     "concept_id" TEXT,
ADD COLUMN     "confidence_rating" INTEGER,
ADD COLUMN     "response_id" BIGSERIAL NOT NULL,
ADD COLUMN     "selected_answer" TEXT,
ADD COLUMN     "session_date" DATE,
ADD COLUMN     "time_taken_ms" BIGINT NOT NULL DEFAULT 0,
ADD COLUMN     "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD CONSTRAINT "session_answers_pkey" PRIMARY KEY ("response_id");

-- AlterTable
ALTER TABLE "sessions" ADD COLUMN     "quiz_type" TEXT DEFAULT 'diagnostic',
ADD COLUMN     "score_percent" DOUBLE PRECISION,
ADD COLUMN     "total_correct" INTEGER;

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- CreateTable
CREATE TABLE "student_profiles" (
    "user_id" TEXT NOT NULL,
    "section" TEXT,
    "gender" TEXT,
    "medium" TEXT,
    "class9_marks" DOUBLE PRECISION,
    "interest_rating" INTEGER,
    "chapter_studied" TEXT,
    "study_hours" DOUBLE PRECISION,
    "school" TEXT,
    "class_grade" INTEGER,

    CONSTRAINT "student_profiles_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "concepts" (
    "concept_id" TEXT NOT NULL,
    "concept_name" TEXT NOT NULL,
    "description" TEXT,
    "chapter" TEXT,
    "ncert_section" TEXT,
    "bloom_level" TEXT,
    "difficulty_level" INTEGER,
    "concept_type" TEXT,
    "misconception" TEXT,
    "formula" TEXT,
    "unit" TEXT,
    "quiz_in_scope" TEXT,

    CONSTRAINT "concepts_pkey" PRIMARY KEY ("concept_id")
);

-- CreateTable
CREATE TABLE "student_masteries" (
    "student_id" TEXT NOT NULL,
    "concept_id" TEXT NOT NULL,
    "mastery_prob" DOUBLE PRECISION NOT NULL DEFAULT 0.2,
    "attempt_count" INTEGER NOT NULL DEFAULT 0,
    "correct_count" INTEGER NOT NULL DEFAULT 0,
    "last_seen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "student_masteries_pkey" PRIMARY KEY ("student_id","concept_id")
);

-- CreateTable
CREATE TABLE "_ConceptToQuestion" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_ConceptToQuestion_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "_ConceptPrerequisites" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_ConceptPrerequisites_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE UNIQUE INDEX "concepts_concept_name_key" ON "concepts"("concept_name");

-- CreateIndex
CREATE INDEX "_ConceptToQuestion_B_index" ON "_ConceptToQuestion"("B");

-- CreateIndex
CREATE INDEX "_ConceptPrerequisites_B_index" ON "_ConceptPrerequisites"("B");

-- CreateIndex
CREATE INDEX "question_events_session_id_created_at_idx" ON "question_events"("session_id", "created_at");

-- CreateIndex
CREATE INDEX "question_events_archived_at_idx" ON "question_events"("archived_at");

-- CreateIndex
CREATE INDEX "session_answers_session_id_idx" ON "session_answers"("session_id");

-- CreateIndex
CREATE INDEX "session_answers_question_id_idx" ON "session_answers"("question_id");

-- CreateIndex
CREATE UNIQUE INDEX "session_answers_session_id_question_id_key" ON "session_answers"("session_id", "question_id");

-- AddForeignKey
ALTER TABLE "student_profiles" ADD CONSTRAINT "student_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quizzes" ADD CONSTRAINT "quizzes_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_events" ADD CONSTRAINT "question_events_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("question_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "session_answers" ADD CONSTRAINT "session_answers_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("question_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "session_answers" ADD CONSTRAINT "session_answers_concept_id_fkey" FOREIGN KEY ("concept_id") REFERENCES "concepts"("concept_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_masteries" ADD CONSTRAINT "student_masteries_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_masteries" ADD CONSTRAINT "student_masteries_concept_id_fkey" FOREIGN KEY ("concept_id") REFERENCES "concepts"("concept_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ConceptToQuestion" ADD CONSTRAINT "_ConceptToQuestion_A_fkey" FOREIGN KEY ("A") REFERENCES "concepts"("concept_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ConceptToQuestion" ADD CONSTRAINT "_ConceptToQuestion_B_fkey" FOREIGN KEY ("B") REFERENCES "questions"("question_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ConceptPrerequisites" ADD CONSTRAINT "_ConceptPrerequisites_A_fkey" FOREIGN KEY ("A") REFERENCES "concepts"("concept_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ConceptPrerequisites" ADD CONSTRAINT "_ConceptPrerequisites_B_fkey" FOREIGN KEY ("B") REFERENCES "concepts"("concept_id") ON DELETE CASCADE ON UPDATE CASCADE;

